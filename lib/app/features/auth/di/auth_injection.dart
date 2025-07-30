import 'package:get_it/get_it.dart';

// Auth Feature Imports
import '../data/repository/repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/send_phone_otp_usecase.dart';
import '../domain/usecases/verify_phone_otp_usecase.dart';
import '../domain/usecases/send_email_otp_usecase.dart';
import '../domain/usecases/verify_email_otp_usecase.dart';
import '../domain/usecases/check_agent_card_exists_usecase.dart';
import '../domain/usecases/check_user_profile_completeness_usecase.dart';
import '../domain/usecases/create_agent_card_usecase.dart';
import '../domain/usecases/sign_out_usecase.dart';
import '../presentation/bloc/auth_bloc.dart';

/// Service locator instance
final sl = GetIt.instance;

/// Initialize Auth Feature dependencies using Clean Architecture
void initializeAuthFeature() {
  // ===== REPOSITORIES =====
  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(),
  );

  // ===== USE CASES =====
  // Send Phone OTP Use Case
  sl.registerLazySingleton<SendPhoneOtpUseCase>(
    () => SendPhoneOtpUseCase(sl<AuthRepository>()),
  );

  // Verify Phone OTP Use Case
  sl.registerLazySingleton<VerifyPhoneOtpUseCase>(
    () => VerifyPhoneOtpUseCase(sl<AuthRepository>()),
  );

  // Send Email OTP Use Case
  sl.registerLazySingleton<SendEmailOtpUseCase>(
    () => SendEmailOtpUseCase(sl<AuthRepository>()),
  );

  // Verify Email OTP Use Case
  sl.registerLazySingleton<VerifyEmailOtpUseCase>(
    () => VerifyEmailOtpUseCase(sl<AuthRepository>()),
  );

  // Check Agent Card Exists Use Case
  sl.registerLazySingleton<CheckAgentCardExistsUseCase>(
    () => CheckAgentCardExistsUseCase(sl<AuthRepository>()),
  );

  // Check User Profile Completeness Use Case
  sl.registerLazySingleton<CheckUserProfileCompletenessUseCase>(
    () => CheckUserProfileCompletenessUseCase(sl<AuthRepository>()),
  );

  // Create Agent Card Use Case
  sl.registerLazySingleton<CreateAgentCardUseCase>(
    () => CreateAgentCardUseCase(sl<AuthRepository>()),
  );

  // Sign Out Use Case
  sl.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(sl<AuthRepository>()),
  );

  // ===== BLOCS =====
  // Auth BLoC
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      sendPhoneOtpUseCase: sl<SendPhoneOtpUseCase>(),
      verifyPhoneOtpUseCase: sl<VerifyPhoneOtpUseCase>(),
      sendEmailOtpUseCase: sl<SendEmailOtpUseCase>(),
      verifyEmailOtpUseCase: sl<VerifyEmailOtpUseCase>(),
      checkAgentCardExistsUseCase: sl<CheckAgentCardExistsUseCase>(),
      checkUserProfileCompletenessUseCase:
          sl<CheckUserProfileCompletenessUseCase>(),
      createAgentCardUseCase: sl<CreateAgentCardUseCase>(),
      signOutUseCase: sl<SignOutUseCase>(),
    ),
  );
}
