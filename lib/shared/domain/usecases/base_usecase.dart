import '../../../core/errors/failures.dart';

/// Result wrapper that represents either success or failure
sealed class Result<T> {
  const Result();
}

/// Success result containing data
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Failure result containing error
class Failed<T> extends Result<T> {
  final Failure failure;
  const Failed(this.failure);
}

/// Base interface for all use cases in the application
/// 
/// [Type] - The return type of the use case
/// [Params] - The parameters required by the use case
abstract class UseCase<Type, Params> {
  /// Execute the use case with given parameters
  /// Returns Result<Type> where:
  /// - Success contains the result data
  /// - Failed contains the Failure
  Future<Result<Type>> call(Params params);
}

/// Use case that doesn't require any parameters
abstract class NoParamsUseCase<Type> {
  /// Execute the use case without parameters
  /// Returns Result<Type> where:
  /// - Success contains the result data
  /// - Failed contains the Failure
  Future<Result<Type>> call();
}

/// Synchronous use case with parameters
abstract class SyncUseCase<Type, Params> {
  /// Execute the synchronous use case with given parameters
  /// Returns Result<Type> where:
  /// - Success contains the result data
  /// - Failed contains the Failure
  Result<Type> call(Params params);
}

/// Synchronous use case without parameters
abstract class SyncNoParamsUseCase<Type> {
  /// Execute the synchronous use case without parameters
  /// Returns Result<Type> where:
  /// - Success contains the result data
  /// - Failed contains the Failure
  Result<Type> call();
}

/// Stream-based use case with parameters
abstract class StreamUseCase<Type, Params> {
  /// Execute the stream use case with given parameters
  /// Returns Stream<Result<Type>> where:
  /// - Success contains the result data per emission
  /// - Failed contains the Failure per emission
  Stream<Result<Type>> call(Params params);
}

/// Stream-based use case without parameters
abstract class StreamNoParamsUseCase<Type> {
  /// Execute the stream use case without parameters
  /// Returns Stream<Result<Type>> where:
  /// - Success contains the result data per emission
  /// - Failed contains the Failure per emission
  Stream<Result<Type>> call();
}

/// Special class for use cases that don't need parameters
class NoParams {
  const NoParams();
}

/// Base class for use case parameters to ensure they are equatable
abstract class UseCaseParams {
  const UseCaseParams();
} 