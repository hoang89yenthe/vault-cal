import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';

part 'posts_state.dart';

class PostsCubit extends Cubit<PostsState> {
  PostsCubit(this._repository) : super(const PostsInitial());

  final PostRepository _repository;

  Future<void> fetchPosts() async {
    emit(const PostsLoading());

    final result = await _repository.getPosts();
    switch (result) {
      case Ok(:final value):
        emit(PostsLoaded(value));
      case Err(:final failure):
        emit(PostsError(failure.message));
    }
  }
}
