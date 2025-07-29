import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import 'package:hushh_agent_app/core/errors/failures.dart';
import '../entities/agent_category.dart';
import '../repositories/auth_repository.dart';

class GetAgentCategoriesUseCase implements UseCase<List<AgentCategory>, NoParams> {
  final AuthRepository _authRepository;

  GetAgentCategoriesUseCase(this._authRepository);

  @override
  Future<Result<List<AgentCategory>>> call(NoParams params) async {
    try {
      final categories = await _authRepository.getAgentCategories();
      return Success(categories);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
}

class NoParams {
  const NoParams();
} 