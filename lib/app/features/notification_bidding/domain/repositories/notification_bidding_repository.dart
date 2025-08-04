import '../entities/fcm_token.dart';

abstract class NotificationBiddingRepository {
  /// Save FCM token to Firestore
  Future<void> saveFcmToken(String token, String platform);

  /// Get FCM token for current user
  Future<FcmToken?> getFcmToken();

  /// Update FCM token
  Future<void> updateFcmToken(String token);

  /// Delete FCM token
  Future<void> deleteFcmToken();
}
