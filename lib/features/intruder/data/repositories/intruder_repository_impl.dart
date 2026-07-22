import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../../core/db/vault_database.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/security/file_crypto.dart';
import '../../../../core/security/key_manager.dart';
import '../../../../core/session/vault_session.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/intruder_event.dart';
import '../../domain/repositories/intruder_repository.dart';

/// Records and reads intruder events in the REAL namespace, independent of any
/// active session (capture happens before authentication).
class IntruderRepositoryImpl implements IntruderRepository {
  IntruderRepositoryImpl(this._keyManager);

  final KeyManager _keyManager;
  final _uuid = const Uuid();

  @override
  Future<void> record({required int attemptCount, Uint8List? photo}) async {
    final handle = await VaultSession.openStandalone(
      _keyManager,
      VaultSession.realNamespace,
    );
    try {
      final id = _uuid.v4();
      String? relPath;
      String? wrappedDek;

      if (photo != null) {
        final wrapped = await _keyManager.newWrappedDek(
          VaultSession.realNamespace,
        );
        relPath = 'intruder/$id.vlt';
        wrappedDek = wrapped.wrapped;
        await FileCrypto.encryptBytes(
          bytes: photo,
          destPath: p.join(handle.root, relPath),
          dek: wrapped.dek,
        );
      }

      await handle.db
          .into(handle.db.intruderEvents)
          .insert(
            IntruderEventsCompanion.insert(
              id: id,
              timestamp: DateTime.now().millisecondsSinceEpoch,
              attemptCount: attemptCount,
              photoRelPath: Value(relPath),
              wrappedDek: Value(wrappedDek),
            ),
          );
    } on Object {
      // Best-effort: never surface capture/record failures to the UI.
    } finally {
      await handle.db.close();
    }
  }

  @override
  Future<Result<List<IntruderEvent>>> listEvents() async {
    final handle = await VaultSession.openStandalone(
      _keyManager,
      VaultSession.realNamespace,
    );
    try {
      final rows = await (handle.db.select(
        handle.db.intruderEvents,
      )..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).get();

      final events = <IntruderEvent>[];
      for (final row in rows) {
        Uint8List? photo;
        if (row.photoRelPath != null && row.wrappedDek != null) {
          final path = p.join(handle.root, row.photoRelPath!);
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
        events.add(
          IntruderEvent(
            id: row.id,
            timestamp: DateTime.fromMillisecondsSinceEpoch(row.timestamp),
            attemptCount: row.attemptCount,
            photo: photo,
          ),
        );
      }
      return Ok(events);
    } on Object catch (e) {
      return Err(StorageFailure(e.toString()));
    } finally {
      await handle.db.close();
    }
  }
}
