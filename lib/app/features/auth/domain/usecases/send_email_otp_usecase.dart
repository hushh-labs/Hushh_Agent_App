import 'package:hushh_agent_app/core/errors/failures.dart';
import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import '../repositories/auth_repository.dart';

class SendEmailOtpParams {
  final String email;

  SendEmailOtpParams({required this.email});
}

class SendEmailOtpUseCase extends UseCase<void, SendEmailOtpParams> {
  final AuthRepository repository;

  SendEmailOtpUseCase(this.repository);

  @override
  Future<Result<void>> call(SendEmailOtpParams params) async {
    try {
      await repository.sendEmailOtp(params.email);
      return Success(null);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
} 