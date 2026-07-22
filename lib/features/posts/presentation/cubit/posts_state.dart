part of 'posts_cubit.dart';

sealed class PostsState extends Equatable {
  const PostsState();

  @override
  List<Object?> get props => [];
}

final class PostsInitial extends PostsState {
  const PostsInitial();
}

final class PostsLoading extends PostsState {
  const PostsLoading();
}

final class PostsLoaded extends PostsState {
  const PostsLoaded(this.posts);

  final List<Post> posts;

  @override
  List<Object?> get props => [posts];
}

final class PostsError extends PostsState {
  const PostsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
