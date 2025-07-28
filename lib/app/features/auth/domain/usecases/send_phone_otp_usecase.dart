import 'package:hushh_agent_app/core/errors/failures.dart';
import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import '../repositories/auth_repository.dart';

class SendPhoneOtpUseCase implements UseCase<void, SendPhoneOtpParams> {
  final AuthRepository _authRepository;

  SendPhoneOtpUseCase(this._authRepository);

  @override
  Future<Result<void>> call(SendPhoneOtpParams params) async {
    try {
      await _authRepository.signInWithPhoneNumber(params.phoneNumber);
      return const Success(null);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
}

class SendPhoneOtpParams {
  final String phoneNumber;
  final Function(String phoneNumber)? onOtpSent;

  SendPhoneOtpParams({required this.phoneNumber, this.onOtpSent});
}