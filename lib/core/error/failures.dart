import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

final class CryptoFailure extends Failure {
  const CryptoFailure([super.message = 'Encryption error occurred']);
}

final class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage error occurred']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

final class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unexpected error occurred']);
}
