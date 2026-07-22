import '../../../../core/utils/result.dart';
import '../entities/vault_note.dart';

abstract interface class NotesRepository {
  Future<Result<List<VaultNote>>> listNotes();

  /// Creates or updates a note. Pass a null [id] to create.
  Future<Result<void>> saveNote({
    String? id,
    required String title,
    required String body,
  });

  Future<Result<void>> deleteNote(String id);
}
