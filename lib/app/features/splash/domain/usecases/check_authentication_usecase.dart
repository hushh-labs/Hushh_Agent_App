import '../repositories/splash_repository.dart';
import '../../../../../shared/core/use_cases/usecase.dart';

/// Use case for checking if agent is authenticated
class CheckAuthenticationUseCase implements UseCase<bool, NoParams> {
  final SplashRepository repository;

  CheckAuthenticationUseCase(this.repository);

  @override
  Future<bool> call(NoParams params) async {
    try {
      return await repository.isAgentAuthenticated();
    } catch (e) {
      return false;
    }
  }
} 