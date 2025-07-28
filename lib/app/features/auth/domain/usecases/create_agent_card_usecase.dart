import 'package:hushh_agent_app/core/errors/failures.dart';
import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import '../repositories/auth_repository.dart';
import '../entities/agent_card.dart';

/// Parameters for creating an agent card
class CreateAgentCardParams {
  final AgentCard agentCard;

  CreateAgentCardParams({required this.agentCard});
}

/// Use case for creating an agent card
class CreateAgentCardUseCase implements UseCase<void, CreateAgentCardParams> {
  final AuthRepository _authRepository;

  CreateAgentCardUseCase(this._authRepository);

  @override
  Future<Result<void>> call(CreateAgentCardParams params) async {
    try {
      await _authRepository.createAgentCard(params.agentCard);
      return const Success(null);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
}
