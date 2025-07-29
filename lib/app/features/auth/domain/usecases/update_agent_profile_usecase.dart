import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import 'package:hushh_agent_app/core/errors/failures.dart';
import '../entities/hushh_agent.dart';
import '../repositories/auth_repository.dart';

class UpdateAgentProfileParams {
  final String agentId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? name;
  final String? agentProfileImage;
  final String? selectedReasonForUsingHushh;
  final OnboardStatus? onboardStatus;
  final String? selectedCategoryId;
  final String? selectedBrandId;

  const UpdateAgentProfileParams({
    required this.agentId,
    this.firstName,
    this.lastName,
    this.email,
    this.name,
    this.agentProfileImage,
    this.selectedReasonForUsingHushh,
    this.onboardStatus,
    this.selectedCategoryId,
    this.selectedBrandId,
  });
}

class UpdateAgentProfileUseCase implements UseCase<void, UpdateAgentProfileParams> {
  final AuthRepository _authRepository;

  UpdateAgentProfileUseCase(this._authRepository);

  @override
  Future<Result<void>> call(UpdateAgentProfileParams params) async {
    try {
      await _authRepository.updateAgentProfile(params);
      return const Success(null);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
} 