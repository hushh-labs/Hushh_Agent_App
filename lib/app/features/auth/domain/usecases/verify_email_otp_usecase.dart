import 'package:firebase_auth/firebase_auth.dart';
import 'package:hushh_agent_app/core/errors/failures.dart';
import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailOtpParams {
  final String email;
  final String otp;

  VerifyEmailOtpParams({required this.email, required this.otp});
}

class VerifyEmailOtpUseCase extends UseCase<UserCredential, VerifyEmailOtpParams> {
  final AuthRepository repository;

  VerifyEmailOtpUseCase(this.repository);

  @override
  Future<Result<UserCredential>> call(VerifyEmailOtpParams params) async {
    try {
      final result = await repository.verifyEmailOtp(params.email, params.otp);
      return Success(result);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
} 