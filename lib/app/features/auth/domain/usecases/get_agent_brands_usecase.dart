import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import 'package:hushh_agent_app/core/errors/failures.dart';
import '../entities/agent_brand.dart';
import '../repositories/auth_repository.dart';

class GetAgentBrandsParams {
  final String categoryId;

  const GetAgentBrandsParams({required this.categoryId});
}

class GetAgentBrandsUseCase implements UseCase<List<AgentBrand>, GetAgentBrandsParams> {
  final AuthRepository _authRepository;

  GetAgentBrandsUseCase(this._authRepository);

  @override
  Future<Result<List<AgentBrand>>> call(GetAgentBrandsParams params) async {
    try {
      final brands = await _authRepository.getAgentBrandsByCategory(params.categoryId);
      return Success(brands);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
} 