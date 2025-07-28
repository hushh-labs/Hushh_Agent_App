import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:hushh_agent_app/core/errors/failures.dart';
import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyPhoneOtpParams {
  final String verificationId;
  final String otp;

  VerifyPhoneOtpParams({required this.verificationId, required this.otp});
}

class VerifyPhoneOtpUseCase
    implements UseCase<firebase_auth.UserCredential, VerifyPhoneOtpParams> {
  final AuthRepository _authRepository;

  VerifyPhoneOtpUseCase(this._authRepository);

  @override
  Future<Result<firebase_auth.UserCredential>> call(
    VerifyPhoneOtpParams params,
  ) async {
    try {
      final result = await _authRepository.verifyOTP(
        params.verificationId,
        params.otp,
      );
      return Success(result);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
}