import '../../../../core/utils/result.dart';
import '../entities/post.dart';

abstract interface class PostRepository {
  Future<Result<List<Post>>> getPosts();
}
