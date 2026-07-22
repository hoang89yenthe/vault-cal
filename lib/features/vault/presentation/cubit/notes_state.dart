part of 'notes_cubit.dart';

sealed class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

final class NotesLoading extends NotesState {
  const NotesLoading();
}

final class NotesLoaded extends NotesState {
  const NotesLoaded(this.notes);

  final List<VaultNote> notes;

  @override
  List<Object?> get props => [notes];
}

final class NotesError extends NotesState {
  const NotesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
