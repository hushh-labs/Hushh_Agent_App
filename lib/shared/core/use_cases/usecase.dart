import 'package:equatable/equatable.dart';

/// Base interface for all use cases
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Use this class when a use case doesn't need any parameters
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
} 