import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vault_cal/core/error/failures.dart';
import 'package:vault_cal/core/utils/result.dart';
import 'package:vault_cal/features/posts/domain/entities/post.dart';
import 'package:vault_cal/features/posts/domain/repositories/post_repository.dart';
import 'package:vault_cal/features/posts/presentation/cubit/posts_cubit.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository repository;

  const posts = [
    Post(id: 1, title: 'Title 1', body: 'Body 1'),
    Post(id: 2, title: 'Title 2', body: 'Body 2'),
  ];

  setUp(() {
    repository = MockPostRepository();
  });

  group('PostsCubit', () {
    test('initial state is PostsInitial', () {
      expect(PostsCubit(repository).state, const PostsInitial());
    });

    blocTest<PostsCubit, PostsState>(
      'emits [PostsLoading, PostsLoaded] when getPosts succeeds',
      build: () {
        when(
          () => repository.getPosts(),
        ).thenAnswer((_) async => const Ok(posts));
        return PostsCubit(repository);
      },
      act: (cubit) => cubit.fetchPosts(),
      expect: () => const [PostsLoading(), PostsLoaded(posts)],
    );

    blocTest<PostsCubit, PostsState>(
      'emits [PostsLoading, PostsError] when getPosts fails',
      build: () {
        when(
          () => repository.getPosts(),
        ).thenAnswer((_) async => const Err(NetworkFailure('offline')));
        return PostsCubit(repository);
      },
      act: (cubit) => cubit.fetchPosts(),
      expect: () => const [PostsLoading(), PostsError('offline')],
    );
  });
}
