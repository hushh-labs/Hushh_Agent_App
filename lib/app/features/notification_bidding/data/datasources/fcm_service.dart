import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Initialize FCM for the app
  Future<void> initialize() async {
    try {
      print('🔄 [FCM] Initializing Firebase Messaging...');
      print('🔍 [FCM] Platform: ${Platform.operatingSystem}');
      print('🔍 [FCM] Platform version: ${Platform.operatingSystemVersion}');

      // Request permission for iOS
      if (Platform.isIOS) {
        print('📱 [FCM] iOS detected, requesting permissions...');
        await _requestIOSPermission();

        // Check if we can get APNS token directly
        print('🔍 [FCM] Checking APNS token availability...');
        try {
          final apnsToken = await _firebaseMessaging.getAPNSToken();
          print('🔍 [FCM] Direct APNS token check: ${apnsToken ?? 'null'}');
        } catch (e) {
          print('🔍 [FCM] Direct APNS token check failed: $e');
        }
      }

      // Get FCM token
      print('🔍 [FCM] Attempting to get FCM token...');
      final token = await _getFcmToken();
      if (token != null) {
        print('✅ [FCM] FCM token obtained: ${token.substring(0, 20)}...');
        print('🔍 [FCM] Full token length: ${token.length}');
      } else {
        print('⚠️ [FCM] Failed to get FCM token');
      }

      // Set up message handlers
      print('🔍 [FCM] Setting up message handlers...');
      _setupMessageHandlers();

      print('✅ [FCM] Firebase Messaging initialized successfully');
    } catch (e) {
      print('❌ [FCM] Error initializing Firebase Messaging: $e');
      print('🔍 [FCM] Error type: ${e.runtimeType}');
      print('🔍 [FCM] Error stack trace: ${StackTrace.current}');
      throw Exception('Failed to initialize FCM: ${e.toString()}');
    }
  }

  /// Request permission for iOS
  Future<void> _requestIOSPermission() async {
    try {
      print('🔍 [FCM] Requesting iOS notification permissions...');
      print('🔍 [FCM] Current authorization status before request...');

      // Check current authorization status
      final currentSettings =
          await _firebaseMessaging.getNotificationSettings();
      print(
          '🔍 [FCM] Current authorization status: ${currentSettings.authorizationStatus}');
      print('🔍 [FCM] Current alert setting: ${currentSettings.alert}');
      print('🔍 [FCM] Current badge setting: ${currentSettings.badge}');
      print('🔍 [FCM] Current sound setting: ${currentSettings.sound}');

      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('📱 [FCM] iOS permission status: ${settings.authorizationStatus}');
      print('🔍 [FCM] Alert permission: ${settings.alert}');
      print('🔍 [FCM] Badge permission: ${settings.badge}');
      print('🔍 [FCM] Sound permission: ${settings.sound}');
      print('🔍 [FCM] Announcement permission: ${settings.announcement}');
      print('🔍 [FCM] CarPlay permission: ${settings.carPlay}');
      print('🔍 [FCM] Critical alert permission: ${settings.criticalAlert}');
    } catch (e) {
      print('❌ [FCM] Error requesting iOS permission: $e');
      print('🔍 [FCM] Permission error type: ${e.runtimeType}');
      print('🔍 [FCM] Permission error stack trace: ${StackTrace.current}');
    }
  }

  /// Get FCM token
  Future<String?> _getFcmToken() async {
    try {
      print('🔍 [FCM] Starting FCM token retrieval process...');

      // For iOS, try to get APNS token first
      if (Platform.isIOS) {
        print('🔍 [FCM] iOS detected, checking APNS token...');
        try {
          print('🔍 [FCM] Attempting to get APNS token...');
          final apnsToken = await _firebaseMessaging.getAPNSToken();
          print('📱 [FCM] APNS token: ${apnsToken ?? 'null'}');
          print('🔍 [FCM] APNS token length: ${apnsToken?.length ?? 0}');
          if (apnsToken != null) {
            print(
                '🔍 [FCM] APNS token first 20 chars: ${apnsToken.substring(0, 20)}...');
          }
        } catch (apnsError) {
          print(
              '⚠️ [FCM] APNS token not available (normal on simulator): $apnsError');
          print('🔍 [FCM] APNS error type: ${apnsError.runtimeType}');
          print('🔍 [FCM] APNS error details: $apnsError');
        }
      }

      print('🔍 [FCM] Attempting to get FCM token from Firebase...');
      final token = await _firebaseMessaging.getToken();
      print('🔍 [FCM] FCM token retrieval completed');
      return token;
    } catch (e) {
      print('❌ [FCM] Error getting FCM token: $e');
      print('🔍 [FCM] FCM error type: ${e.runtimeType}');
      print('🔍 [FCM] FCM error details: $e');

      // Handle specific APNS token error
      if (e.toString().contains('apns-token-not-set')) {
        print('📱 [FCM] APNS token not set - this is normal on iOS simulator');
        print('📱 [FCM] FCM tokens work on real devices, not simulators');
        print('🔍 [FCM] This error occurs because:');
        print('🔍 [FCM] 1. iOS Simulator doesn\'t have APNS capabilities');
        print(
            '🔍 [FCM] 2. APNS requires a real device with valid provisioning profile');
        print('🔍 [FCM] 3. FCM tokens depend on APNS token availability');
        return null;
      }

      return null;
    }
  }

  /// Set up message handlers
  void _setupMessageHandlers() {
    print('🔍 [FCM] Setting up Firebase message handlers...');

    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 [FCM] Received foreground message: ${message.messageId}');
      print('📱 [FCM] Message data: ${message.data}');
      print('📱 [FCM] Message notification: ${message.notification?.title}');
      print('🔍 [FCM] Message from: ${message.from}');
      print('🔍 [FCM] Message collapse key: ${message.collapseKey}');
      print('🔍 [FCM] Message sent time: ${message.sentTime}');
      print('🔍 [FCM] Message ttl: ${message.ttl}');

      // TODO: Handle the message (show notification, update UI, etc.)
    });

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 [FCM] App opened from notification: ${message.messageId}');
      print('📱 [FCM] Message data: ${message.data}');
      print('🔍 [FCM] Opened message from: ${message.from}');

      // TODO: Navigate to specific screen based on message data
    });

    // Handle initial message when app is launched from notification
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📱 [FCM] App launched from notification: ${message.messageId}');
        print('📱 [FCM] Message data: ${message.data}');
        print('🔍 [FCM] Initial message from: ${message.from}');

        // TODO: Navigate to specific screen based on message data
      } else {
        print('🔍 [FCM] No initial message found');
      }
    });

    print('🔍 [FCM] Firebase message handlers setup completed');
  }

  /// Get current FCM token
  Future<String?> getCurrentToken() async {
    try {
      print('🔄 [FCM] Getting current FCM token...');
      print('🔍 [FCM] Starting current token retrieval...');

      // For iOS, try to get APNS token first
      if (Platform.isIOS) {
        print(
            '🔍 [FCM] iOS detected, checking APNS token for current token...');
        try {
          print('🔍 [FCM] Attempting to get APNS token for current token...');
          final apnsToken = await _firebaseMessaging.getAPNSToken();
          print('📱 [FCM] APNS token: ${apnsToken ?? 'null'}');
          print('🔍 [FCM] APNS token length: ${apnsToken?.length ?? 0}');
          if (apnsToken != null) {
            print(
                '🔍 [FCM] APNS token first 20 chars: ${apnsToken.substring(0, 20)}...');
          }
        } catch (apnsError) {
          print(
              '⚠️ [FCM] APNS token not available (normal on simulator): $apnsError');
          print('🔍 [FCM] APNS error type: ${apnsError.runtimeType}');
          print('🔍 [FCM] APNS error details: $apnsError');
        }
      }

      print('🔍 [FCM] Attempting to get current FCM token from Firebase...');
      final token = await _firebaseMessaging.getToken();
      print('🔍 [FCM] Current FCM token retrieval completed');

      if (token != null) {
        print('✅ [FCM] Current FCM token: ${token.substring(0, 20)}...');
        print('🔍 [FCM] Current FCM token length: ${token.length}');
      } else {
        print('⚠️ [FCM] No FCM token available');
      }
      return token;
    } catch (e) {
      print('❌ [FCM] Error getting current FCM token: $e');
      print('🔍 [FCM] Current FCM error type: ${e.runtimeType}');
      print('🔍 [FCM] Current FCM error details: $e');

      // Handle specific APNS token error
      if (e.toString().contains('apns-token-not-set')) {
        print('📱 [FCM] APNS token not set - this is normal on iOS simulator');
        print('📱 [FCM] FCM tokens work on real devices, not simulators');
        print('🔍 [FCM] Current token error occurs because:');
        print('🔍 [FCM] 1. iOS Simulator doesn\'t have APNS capabilities');
        print(
            '🔍 [FCM] 2. APNS requires a real device with valid provisioning profile');
        print('🔍 [FCM] 3. FCM tokens depend on APNS token availability');
        return null;
      }

      return null;
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      print('✅ [FCM] FCM token deleted successfully');
    } catch (e) {
      print('❌ [FCM] Error deleting FCM token: $e');
      throw Exception('Failed to delete FCM token: ${e.toString()}');
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ [FCM] Subscribed to topic: $topic');
    } catch (e) {
      print('❌ [FCM] Error subscribing to topic $topic: $e');
      throw Exception('Failed to subscribe to topic: ${e.toString()}');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ [FCM] Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ [FCM] Error unsubscribing from topic $topic: $e');
      throw Exception('Failed to unsubscribe from topic: ${e.toString()}');
    }
  }
}
