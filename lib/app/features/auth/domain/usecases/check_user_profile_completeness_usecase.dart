import 'package:hushh_agent_app/core/errors/failures.dart';
import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import '../repositories/auth_repository.dart';

/// Parameters for checking if user has complete profile
class CheckUserProfileCompletenessParams {
  final String agentId;

  CheckUserProfileCompletenessParams({required this.agentId});
}

/// Use case for checking if a user has complete profile data
class CheckUserProfileCompletenessUseCase
    implements UseCase<bool, CheckUserProfileCompletenessParams> {
  final AuthRepository _authRepository;

  CheckUserProfileCompletenessUseCase(this._authRepository);

  @override
  Future<Result<bool>> call(CheckUserProfileCompletenessParams params) async {
    try {
      final hasCompleteProfile =
          await _authRepository.doesUserHaveCompleteProfile(params.agentId);
      return Success(hasCompleteProfile);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
}
