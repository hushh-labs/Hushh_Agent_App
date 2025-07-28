import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:hushh_agent_app/core/errors/failures.dart';
import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyPhoneOtpParams {
  final String phoneNumber;
  final String otp;

  VerifyPhoneOtpParams({required this.phoneNumber, required this.otp});
}

// Updated to use phoneNumber instead of verificationId
class VerifyPhoneOtpUseCase
    implements UseCase<firebase_auth.UserCredential, VerifyPhoneOtpParams> {
  final AuthRepository _authRepository;

  VerifyPhoneOtpUseCase(this._authRepository);

  @override
  Future<Result<firebase_auth.UserCredential>> call(
    VerifyPhoneOtpParams params,
  ) async {
    try {
      final result = await _authRepository.verifyPhoneOtp(
        params.phoneNumber,
        params.otp,
      );
      return Success(result);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
}