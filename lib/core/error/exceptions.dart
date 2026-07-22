class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred']);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache error occurred']);
}

class CryptoException extends AppException {
  const CryptoException([super.message = 'Encryption error occurred']);
}

class StorageException extends AppException {
  const StorageException([super.message = 'Storage error occurred']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed']);
}

class PermissionException extends AppException {
  const PermissionException([super.message = 'Permission denied']);
}
