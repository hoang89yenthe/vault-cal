part of 'folder_cubit.dart';

sealed class FolderState extends Equatable {
  const FolderState();

  @override
  List<Object?> get props => [];
}

final class FolderLoading extends FolderState {
  const FolderLoading();
}

final class FolderLoaded extends FolderState {
  const FolderLoaded({required this.files, this.selectedIds = const {}});

  final List<VaultFile> files;
  final Set<String> selectedIds;

  bool get selecting => selectedIds.isNotEmpty;

  FolderLoaded copyWith({List<VaultFile>? files, Set<String>? selectedIds}) {
    return FolderLoaded(
      files: files ?? this.files,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }

  @override
  List<Object?> get props => [files, selectedIds];
}

final class FolderError extends FolderState {
  const FolderError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
