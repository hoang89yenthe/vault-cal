import 'dart:io';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/vault_database.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/security/file_crypto.dart';
import '../../../../core/security/key_manager.dart';
import '../../../../core/session/vault_session.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/intruder_event.dart';
import '../../domain/repositories/intruder_repository.dart';

/// Records and reads intruder events in the REAL namespace.
///
/// When the real vault session is already open, its database is reused —
/// opening a second SQLCipher connection to the same file corrupts state and
/// crashes on iOS. A standalone connection is opened only when no real session
/// is active (i.e. capture fires before the user has authenticated).
class IntruderRepositoryImpl implements IntruderRepository {
  IntruderRepositoryImpl(this._keyManager, this._session);

  final KeyManager _keyManager;
  final VaultSession _session;
  final _uuid = const Uuid();

  bool get _realSessionActive => _session.isActive && !_session.isDecoy;

  /// Runs [action] against the real-namespace database, reusing the active
  /// session's connection when possible. [intruderPathOf] resolves a bare
  /// filename to its full path under the real intruder directory.
  Future<T> _withRealVault<T>(
    Future<T> Function(
      VaultDatabase db,
      String Function(String fileName) intruderPathOf,
    )
    action,
  ) async {
    if (_realSessionActive) {
      return action(_session.db, _session.intruderPath);
    }
    final handle = await VaultSession.openStandalone(
      _keyManager,
      VaultSession.realNamespace,
    );
    try {
      return await action(handle.db, (name) => '${handle.root}/intruder/$name');
    } finally {
      await handle.db.close();
    }
  }

  @override
  Future<void> record({required int attemptCount, Uint8List? photo}) async {
    try {
      await _withRealVault((db, intruderPathOf) async {
        final id = _uuid.v4();
        String? fileName;
        String? wrappedDek;

        if (photo != null) {
          final wrapped = await _keyManager.newWrappedDek(
            VaultSession.realNamespace,
          );
          fileName = '$id.vlt';
          wrappedDek = wrapped.wrapped;
          await FileCrypto.encryptBytes(
            bytes: photo,
            destPath: intruderPathOf(fileName),
            dek: wrapped.dek,
          );
        }

        await db
            .into(db.intruderEvents)
            .insert(
              IntruderEventsCompanion.insert(
                id: id,
                timestamp: DateTime.now().millisecondsSinceEpoch,
                attemptCount: attemptCount,
                photoRelPath: Value(fileName),
                wrappedDek: Value(wrappedDek),
              ),
            );
      });
    } on Object {
      // Best-effort: never surface capture/record failures to the UI.
    }
  }

  @override
  Future<Result<List<IntruderEvent>>> listEvents() async {
    try {
      final events = await _withRealVault((db, intruderPathOf) async {
        final rows = await (db.select(
          db.intruderEvents,
        )..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).get();

        final result = <IntruderEvent>[];
        for (final row in rows) {
          Uint8List? photo;
          if (row.photoRelPath != null && row.wrappedDek != null) {
            final path = intruderPathOf(row.photoRelPath!);
            if (File(path).existsSync()) {
              try {
                final dek = await _keyManager.unwrapDek(
                  VaultSession.realNamespace,
                  row.wrappedDek!,
                );
                photo = await FileCrypto.decryptToBytes(
                  sourcePath: path,
                  dek: dek,
                );
              } on Object {
                photo = null;
              }
            }
          }
          result.add(
            IntruderEvent(
              id: row.id,
              timestamp: DateTime.fromMillisecondsSinceEpoch(row.timestamp),
              attemptCount: row.attemptCount,
              photo: photo,
            ),
          );
        }
        return result;
      });
      return Ok(events);
    } on Object catch (e) {
      return Err(StorageFailure(e.toString()));
    }
  }
}
