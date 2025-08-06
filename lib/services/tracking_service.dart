// services/tracking_service.dart
import 'package:flutter/services.dart';

enum TrackingStatus {
  authorized,
  denied,
  notDetermined,
  restricted,
  notSupported,
  unknown
}

class TrackingService {
  static const MethodChannel _channel = MethodChannel('com.hushh.app/tracking');

  /// Request tracking authorization from the user
  static Future<TrackingStatus> requestTrackingAuthorization() async {
    try {
      final String status =
          await _channel.invokeMethod('requestTrackingAuthorization');
      return _parseTrackingStatus(status);
    } on PlatformException catch (e) {
      print('Error requesting tracking authorization: ${e.message}');
      return TrackingStatus.unknown;
    }
  }

  /// Get the current tracking authorization status
  static Future<TrackingStatus> getTrackingStatus() async {
    try {
      final String status = await _channel.invokeMethod('getTrackingStatus');
      return _parseTrackingStatus(status);
    } on PlatformException catch (e) {
      print('Error getting tracking status: ${e.message}');
      return TrackingStatus.unknown;
    }
  }

  static TrackingStatus _parseTrackingStatus(String status) {
    switch (status) {
      case 'authorized':
        return TrackingStatus.authorized;
      case 'denied':
        return TrackingStatus.denied;
      case 'notDetermined':
        return TrackingStatus.notDetermined;
      case 'restricted':
        return TrackingStatus.restricted;
      case 'notSupported':
        return TrackingStatus.notSupported;
      default:
        return TrackingStatus.unknown;
    }
  }
}
