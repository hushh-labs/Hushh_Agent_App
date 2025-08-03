import 'dart:io';
import 'package:hushh_agent_app/core/errors/failures.dart';
import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import '../../../notification_bidding/domain/repositories/notification_bidding_repository.dart';
import '../../../notification_bidding/data/datasources/fcm_service.dart';

class SaveFcmTokenAfterLoginUseCase implements UseCase<void, void> {
  final NotificationBiddingRepository _notificationRepository;

  SaveFcmTokenAfterLoginUseCase(this._notificationRepository);

  @override
  Future<Result<void>> call(void params) async {
    try {
      // Determine platform
      String platform;
      if (Platform.isIOS) {
        platform = 'ios';
      } else if (Platform.isAndroid) {
        platform = 'android';
      } else {
        platform = 'web';
      }

      // Get FCM token from Firebase Messaging
      final fcmService = FcmService();
      await fcmService.initialize();

      final token = await fcmService.getCurrentToken();
      if (token != null) {
        // Save FCM token to Firestore
        await _notificationRepository.saveFcmToken(token, platform);
        print('✅ [AUTH] FCM token saved after login for platform: $platform');
      } else {
        print('⚠️ [AUTH] Failed to get FCM token after login');
      }

      return const Success(null);
    } catch (e) {
      print('❌ [AUTH] Error saving FCM token after login: $e');
      return Failed(ServerFailure(e.toString()));
    }
  }
}
