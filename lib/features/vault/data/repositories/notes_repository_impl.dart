import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/vault_database.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/session/vault_session.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/vault_note.dart';
import '../../domain/repositories/notes_repository.dart';

/// Notes CRUD. Bodies live inside the SQLCipher database, so they are already
/// encrypted at rest — no separate file crypto needed.
class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl(this._session);

  final VaultSession _session;
  final _uuid = const Uuid();

  VaultDatabase get _db => _session.db;

  @override
  Future<Result<List<VaultNote>>> listNotes() async {
    try {
      final rows = await (_db.select(_db.notes)
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();
      return Ok(rows.map(_map).toList());
    } on Object catch (e) {
      return Err(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> saveNote({
    String? id,
    required String title,
    required String body,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (id == null) {
        await _db.into(_db.notes).insert(
              NotesCompanion.insert(
                id: _uuid.v4(),
                title: title,
                body: body,
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        await (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(
          NotesCompanion(
            title: Value(title),
            body: Value(body),
            updatedAt: Value(now),
          ),
        );
      }
      return const Ok(null);
    } on Object catch (e) {
      return Err(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteNote(String id) async {
    try {
      await (_db.delete(_db.notes)..where((t) => t.id.equals(id))).go();
      return const Ok(null);
    } on Object catch (e) {
      return Err(StorageFailure(e.toString()));
    }
  }

  VaultNote _map(NoteRow row) => VaultNote(
        id: row.id,
        title: row.title,
        body: row.body,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
      );
}
