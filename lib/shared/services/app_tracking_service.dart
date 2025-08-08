import 'package:flutter/services.dart';

enum TrackingAuthorizationStatus {
  notDetermined,
  restricted,
  denied,
  authorized,
  unknown,
}

class AppTrackingService {
  static const MethodChannel _channel = MethodChannel('app_tracking_transparency');
  
  /// Request tracking authorization from the user
  static Future<void> requestTrackingAuthorization() async {
    try {
      await _channel.invokeMethod('requestTrackingAuthorization');
    } on PlatformException catch (e) {
      print('Error requesting tracking authorization: ${e.message}');
    }
  }
  
  /// Get the current tracking authorization status
  static Future<TrackingAuthorizationStatus> getTrackingAuthorizationStatus() async {
    try {
      final String status = await _channel.invokeMethod('getTrackingAuthorizationStatus');
      return _parseStatus(status);
    } on PlatformException catch (e) {
      print('Error getting tracking authorization status: ${e.message}');
      return TrackingAuthorizationStatus.unknown;
    }
  }
  
  /// Get the advertising identifier (IDFA) if authorized
  static Future<String> getAdvertisingIdentifier() async {
    try {
      final String idfa = await _channel.invokeMethod('getAdvertisingIdentifier');
      return idfa;
    } on PlatformException catch (e) {
      print('Error getting advertising identifier: ${e.message}');
      return '';
    }
  }
  
  /// Set up listener for tracking authorization status changes
  static void setTrackingAuthorizationStatusListener(Function(TrackingAuthorizationStatus) listener) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'trackingAuthorizationStatusChanged') {
        final String status = call.arguments as String;
        listener(_parseStatus(status));
      }
    });
  }
  
  /// Parse status string to enum
  static TrackingAuthorizationStatus _parseStatus(String status) {
    switch (status) {
      case 'authorized':
        return TrackingAuthorizationStatus.authorized;
      case 'denied':
        return TrackingAuthorizationStatus.denied;
      case 'restricted':
        return TrackingAuthorizationStatus.restricted;
      case 'notDetermined':
        return TrackingAuthorizationStatus.notDetermined;
      default:
        return TrackingAuthorizationStatus.unknown;
    }
  }
  
  /// Check if tracking is authorized
  static Future<bool> isTrackingAuthorized() async {
    final status = await getTrackingAuthorizationStatus();
    return status == TrackingAuthorizationStatus.authorized;
  }
  
  /// Get status description for UI
  static String getStatusDescription(TrackingAuthorizationStatus status) {
    switch (status) {
      case TrackingAuthorizationStatus.authorized:
        return 'Tracking is authorized';
      case TrackingAuthorizationStatus.denied:
        return 'Tracking is denied';
      case TrackingAuthorizationStatus.restricted:
        return 'Tracking is restricted';
      case TrackingAuthorizationStatus.notDetermined:
        return 'Tracking permission not determined';
      case TrackingAuthorizationStatus.unknown:
        return 'Tracking status unknown';
    }
  }
}
