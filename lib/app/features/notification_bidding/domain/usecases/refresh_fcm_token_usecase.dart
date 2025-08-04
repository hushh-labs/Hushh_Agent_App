import 'dart:io';
import 'package:hushh_agent_app/core/errors/failures.dart';
import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import '../repositories/notification_bidding_repository.dart';
import '../../data/datasources/fcm_service.dart';

class RefreshFcmTokenUseCase implements UseCase<void, void> {
  final NotificationBiddingRepository _notificationRepository;

  RefreshFcmTokenUseCase(this._notificationRepository);

  @override
  Future<Result<void>> call(void params) async {
    try {
      print('🔄 [FCM] Refreshing FCM token on app open...');

      // Determine platform
      String platform;
      if (Platform.isIOS) {
        platform = 'ios';
      } else if (Platform.isAndroid) {
        platform = 'android';
      } else {
        platform = 'web';
      }

      // Initialize FCM and get current token
      final fcmService = FcmService();
      await fcmService.initialize();

      final token = await fcmService.getCurrentToken();
      if (token != null) {
        // Update FCM token in Firestore
        await _notificationRepository.updateFcmToken(token);
        print(
            '✅ [FCM] FCM token refreshed successfully for platform: $platform');
      } else {
        print('⚠️ [FCM] Failed to get FCM token for refresh');
      }

      return const Success(null);
    } catch (e) {
      print('❌ [FCM] Error refreshing FCM token: $e');
      return Failed(ServerFailure(e.toString()));
    }
  }
}
