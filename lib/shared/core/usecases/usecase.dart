import 'package:equatable/equatable.dart';

/// Abstract class for Use Cases
/// Type: The return type of the use case
/// Params: The parameters that the use case needs
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Used when a use case doesn't need any parameters
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
} 