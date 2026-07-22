import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/vault_file.dart';
import '../../domain/repositories/media_repository.dart';

part 'folder_state.dart';

class FolderCubit extends Cubit<FolderState> {
  FolderCubit(this._media) : super(const FolderLoading());

  final MediaRepository _media;
  late MediaCategory _category;

  Future<void> load(MediaCategory category) async {
    _category = category;
    emit(const FolderLoading());
    final result = await _media.listFiles(category);
    switch (result) {
      case Ok(:final value):
        emit(FolderLoaded(files: value));
      case Err(:final failure):
        emit(FolderError(failure.message));
    }
  }

  void toggleSelect(String id) {
    final state = this.state;
    if (state is! FolderLoaded) return;
    final selected = Set<String>.from(state.selectedIds);
    if (!selected.add(id)) selected.remove(id);
    emit(state.copyWith(selectedIds: selected));
  }

  void clearSelection() {
    final state = this.state;
    if (state is FolderLoaded) {
      emit(state.copyWith(selectedIds: const {}));
    }
  }

  Future<void> deleteSelected() async {
    final state = this.state;
    if (state is! FolderLoaded || state.selectedIds.isEmpty) return;
    await _media.deleteFiles(state.selectedIds.toList());
    await load(_category);
  }
}
