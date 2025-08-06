import 'package:hushh_agent_app/core/errors/failures.dart';
import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import '../repositories/auth_repository.dart';
import '../../../notification_bidding/domain/repositories/notification_bidding_repository.dart';

class SignOutWithFcmCleanupUseCase implements NoParamsUseCase<void> {
  final AuthRepository _authRepository;
  final NotificationBiddingRepository _notificationRepository;

  SignOutWithFcmCleanupUseCase(
      this._authRepository, this._notificationRepository);

  @override
  Future<Result<void>> call() async {
    try {
      // First, delete FCM token
      try {
        await _notificationRepository.deleteFcmToken();
        print('✅ [AUTH] FCM token deleted during sign out');
      } catch (e) {
        print('⚠️ [AUTH] Failed to delete FCM token during sign out: $e');
        // Continue with sign out even if FCM deletion fails
      }

      // Then, perform sign out
      await _authRepository.signOut();
      print('✅ [AUTH] User signed out successfully');

      return const Success(null);
    } catch (e) {
      print('❌ [AUTH] Error during sign out with FCM cleanup: $e');
      return Failed(ServerFailure(e.toString()));
    }
  }
}
