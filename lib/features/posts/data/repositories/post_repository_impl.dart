import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_data_source.dart';

class PostRepositoryImpl implements PostRepository {
  const PostRepositoryImpl(this._remoteDataSource);

  final PostRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Post>>> getPosts() async {
    try {
      final posts = await _remoteDataSource.getPosts();
      return Ok(posts);
    } on NetworkException catch (e) {
      return Err(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } on Exception {
      return const Err(UnknownFailure());
    }
  }
}
