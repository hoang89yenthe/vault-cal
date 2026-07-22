import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/vault_note.dart';
import '../../domain/repositories/notes_repository.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit(this._repository) : super(const NotesLoading());

  final NotesRepository _repository;

  Future<void> load() async {
    emit(const NotesLoading());
    final result = await _repository.listNotes();
    switch (result) {
      case Ok(:final value):
        emit(NotesLoaded(value));
      case Err(:final failure):
        emit(NotesError(failure.message));
    }
  }

  Future<void> save({
    String? id,
    required String title,
    required String body,
  }) async {
    await _repository.saveNote(id: id, title: title, body: body);
    await load();
  }

  Future<void> delete(String id) async {
    await _repository.deleteNote(id);
    await load();
  }
}
