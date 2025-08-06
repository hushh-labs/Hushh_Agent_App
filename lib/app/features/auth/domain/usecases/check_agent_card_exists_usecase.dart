import 'package:hushh_agent_app/core/errors/failures.dart';
import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import '../repositories/auth_repository.dart';

/// Parameters for checking if agent card exists
class CheckAgentCardExistsParams {
  final String agentId;

  CheckAgentCardExistsParams({required this.agentId});
}

/// Use case for checking if an agent card exists
class CheckAgentCardExistsUseCase implements UseCase<bool, CheckAgentCardExistsParams> {
  final AuthRepository _authRepository;

  CheckAgentCardExistsUseCase(this._authRepository);

  @override
  Future<Result<bool>> call(CheckAgentCardExistsParams params) async {
    try {
      final exists = await _authRepository.doesAgentCardExist(params.agentId);
      return Success(exists);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
}
