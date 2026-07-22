import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/post_model.dart';

abstract interface class PostRemoteDataSource {
  Future<List<PostModel>> getPosts();
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  const PostRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<PostModel>> getPosts() async {
    try {
      final response = await _dio.get<List<dynamic>>('/posts');
      return (response.data ?? [])
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw const NetworkException();
        default:
          throw ServerException(e.message ?? 'Server error occurred');
      }
    }
  }
}
