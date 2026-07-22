part of 'import_cubit.dart';

sealed class ImportState extends Equatable {
  const ImportState();

  @override
  List<Object?> get props => [];
}

final class ImportIdle extends ImportState {
  const ImportIdle();
}

final class ImportInProgress extends ImportState {
  const ImportInProgress({required this.done, required this.total});

  final int done;
  final int total;

  @override
  List<Object?> get props => [done, total];
}

final class ImportDone extends ImportState {
  const ImportDone(this.count);

  final int count;

  @override
  List<Object?> get props => [count];
}

final class ImportFailed extends ImportState {
  const ImportFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
