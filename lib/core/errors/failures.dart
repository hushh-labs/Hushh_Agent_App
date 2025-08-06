import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure(String message, {int? code}) : super(message, code: code);
}

/// Network/Internet connection failures
class NetworkFailure extends Failure {
  const NetworkFailure(String message, {int? code}) : super(message, code: code);
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure(String message, {int? code}) : super(message, code: code);
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(String message, {int? code}) : super(message, code: code);
}

/// Authorization failures
class AuthorizationFailure extends Failure {
  const AuthorizationFailure(String message, {int? code}) : super(message, code: code);
}

/// Input validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(String message, {int? code}) : super(message, code: code);
}

/// General failures
class GeneralFailure extends Failure {
  const GeneralFailure(String message, {int? code}) : super(message, code: code);
}

/// Firebase-specific failures
class FirebaseFailure extends Failure {
  const FirebaseFailure(String message, {int? code}) : super(message, code: code);
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure(String message, {int? code}) : super(message, code: code);
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure(String message, {int? code}) : super(message, code: code);
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message, {int? code}) : super(message, code: code);
}

/// Storage failures
class StorageFailure extends Failure {
  const StorageFailure(String message, {int? code}) : super(message, code: code);
} 