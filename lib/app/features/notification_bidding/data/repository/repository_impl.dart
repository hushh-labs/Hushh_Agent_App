import '../../domain/entities/fcm_token.dart';
import '../../domain/repositories/notification_bidding_repository.dart';
import '../datasources/fcm_token_firestore_service.dart';

class NotificationBiddingRepositoryImpl
    implements NotificationBiddingRepository {
  final FcmTokenFirestoreService _fcmTokenService = FcmTokenFirestoreService();

  NotificationBiddingRepositoryImpl() {
    print(
        '🔧 [NOTIFICATION] NotificationBiddingRepositoryImpl instance created: ${this.hashCode}');
  }

  @override
  Future<void> saveFcmToken(String token, String platform) async {
    print(
        '📱 [NOTIFICATION] Save FCM token - Repository instance: ${this.hashCode}');

    try {
      await _fcmTokenService.saveFcmToken(token, platform);
      print('✅ [NOTIFICATION] FCM token saved successfully');
    } catch (e) {
      print('❌ [NOTIFICATION] Failed to save FCM token: $e');
      throw Exception('Failed to save FCM token: ${e.toString()}');
    }
  }

  @override
  Future<FcmToken?> getFcmToken() async {
    print(
        '📱 [NOTIFICATION] Get FCM token - Repository instance: ${this.hashCode}');

    try {
      final fcmToken = await _fcmTokenService.getFcmToken();
      print('✅ [NOTIFICATION] FCM token retrieved successfully');
      return fcmToken;
    } catch (e) {
      print('❌ [NOTIFICATION] Failed to get FCM token: $e');
      throw Exception('Failed to get FCM token: ${e.toString()}');
    }
  }

  @override
  Future<void> updateFcmToken(String token) async {
    print(
        '📱 [NOTIFICATION] Update FCM token - Repository instance: ${this.hashCode}');

    try {
      await _fcmTokenService.updateFcmToken(token);
      print('✅ [NOTIFICATION] FCM token updated successfully');
    } catch (e) {
      print('❌ [NOTIFICATION] Failed to update FCM token: $e');
      throw Exception('Failed to update FCM token: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteFcmToken() async {
    print(
        '📱 [NOTIFICATION] Delete FCM token - Repository instance: ${this.hashCode}');

    try {
      await _fcmTokenService.deleteFcmToken();
      print('✅ [NOTIFICATION] FCM token deleted successfully');
    } catch (e) {
      print('❌ [NOTIFICATION] Failed to delete FCM token: $e');
      throw Exception('Failed to delete FCM token: ${e.toString()}');
    }
  }
}
