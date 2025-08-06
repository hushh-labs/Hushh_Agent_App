import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

/// Utility class for handling permissions with comprehensive state management
class PermissionUtils {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Android Notification Channel
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.high,
  );

  /// Check if a specific permission is granted
  static Future<bool> isPermissionGranted(Permission permission) async {
    return await permission.isGranted;
  }

  /// Get detailed permission status
  static Future<PermissionStatus> getPermissionStatus(Permission permission) async {
    return await permission.status;
  }

  /// Request a single permission with proper handling
  static Future<PermissionStatus> requestPermission(Permission permission) async {
    // Check current status first
    PermissionStatus currentStatus = await permission.status;

    // If already granted, return immediately
    if (currentStatus.isGranted) {
      return currentStatus;
    }

    // If permanently denied, return current status (UI should handle this)
    if (currentStatus.isPermanentlyDenied) {
      return currentStatus;
    }

    // Request the permission
    return await permission.request();
  }

  /// Request multiple permissions at once
  static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }

  /// Handle notification permission with platform-specific logic
  static Future<PermissionStatus> requestNotificationPermission() async {
    if (Platform.isIOS) {
      // iOS specific notification permission
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else {
      // Android specific notification permission
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    return await Permission.notification.status;
  }

  /// Handle location permission with best practices
  static Future<PermissionStatus> requestLocationPermission({
    bool background = false,
  }) async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, return denied status
      return PermissionStatus.denied;
    }

    // Request appropriate location permission
    Permission locationPermission = background 
        ? Permission.locationAlways 
        : Permission.locationWhenInUse;

    return await requestPermission(locationPermission);
  }

  /// Check location permission status (handles multiple permission types)
  static Future<bool> isLocationPermissionGranted() async {
    return (await Permission.locationWhenInUse.isGranted) ||
           (await Permission.locationAlways.isGranted) ||
           (await Permission.location.isGranted);
  }

  /// Open app settings for permission management
  static Future<bool> openPermissionSettings() async {
    return await openAppSettings();
  }

  /// Check if permission should show rationale (Android)
  /// Note: This functionality is handled by the permission_handler package internally
  static Future<bool> shouldShowRequestPermissionRationale(Permission permission) async {
    if (Platform.isAndroid) {
      // Check if permission is denied but not permanently denied
      final status = await permission.status;
      return status.isDenied && !status.isPermanentlyDenied;
    }
    return false;
  }

  /// Get user-friendly permission name
  static String getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Camera';
      case Permission.microphone:
        return 'Microphone';
      case Permission.location:
      case Permission.locationWhenInUse:
      case Permission.locationAlways:
        return 'Location';
      case Permission.contacts:
        return 'Contacts';
      case Permission.photos:
        return 'Photos';
      case Permission.notification:
        return 'Notifications';
      case Permission.storage:
        return 'Storage';
      case Permission.phone:
        return 'Phone';
      default:
        return permission.toString().split('.').last;
    }
  }

  /// Get permission description for user education
  static String getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Take photos and scan QR codes for profile and sharing';
      case Permission.microphone:
        return 'Voice input and audio features for communication';
      case Permission.location:
      case Permission.locationWhenInUse:
      case Permission.locationAlways:
        return 'Location-based features and nearby services';
      case Permission.contacts:
        return 'Connect with people you know and share content';
      case Permission.photos:
        return 'Access your photo library for uploads and sharing';
      case Permission.notification:
        return 'Stay updated with messages and important alerts';
      case Permission.storage:
        return 'Save and access files on your device';
      case Permission.phone:
        return 'Access device information for security';
      default:
        return 'Enable this permission to use related features';
    }
  }

  /// Get permission icon
  static IconData getPermissionIcon(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return Icons.camera_alt_outlined;
      case Permission.microphone:
        return Icons.mic_outlined;
      case Permission.location:
      case Permission.locationWhenInUse:
      case Permission.locationAlways:
        return Icons.location_on_outlined;
      case Permission.contacts:
        return Icons.people_outlined;
      case Permission.photos:
        return Icons.photo_library_outlined;
      case Permission.notification:
        return Icons.notifications_outlined;
      case Permission.storage:
        return Icons.storage_outlined;
      case Permission.phone:
        return Icons.phone_outlined;
      default:
        return Icons.security_outlined;
    }
  }

  /// Check all core permissions status
  static Future<Map<String, bool>> checkAllCorePermissions() async {
    return {
      'notification': await Permission.notification.isGranted,
      'contact': await Permission.contacts.isGranted,
      'location': await isLocationPermissionGranted(),
      'camera': await Permission.camera.isGranted,
      'media': await Permission.photos.isGranted,
      'microphone': await Permission.microphone.isGranted,
    };
  }

  /// Initialize notification system
  static Future<void> initializeNotifications() async {
    // Android initialization
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.createNotificationChannel(channel);
    }

    // iOS initialization
    if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // General initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Debug permission statuses (for development)
  static Future<void> debugPermissionStatuses() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.locationWhenInUse,
      Permission.contacts,
      Permission.photos,
      Permission.notification,
    ];

    print('=== PERMISSION DEBUG ===');
    for (final permission in permissions) {
      final status = await permission.status;
      final isGranted = await permission.isGranted;
      print('${getPermissionName(permission)}: $status (Granted: $isGranted)');
    }
    print('========================');
  }

  /// Handle permission denial with user guidance
  static void handlePermissionDenied({
    required BuildContext context,
    required Permission permission,
    required VoidCallback onRetry,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                getPermissionIcon(permission),
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${getPermissionName(permission)} Permission',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This permission is needed to ${getPermissionDescription(permission).toLowerCase()}.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_outlined,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Grant permission to unlock full functionality',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Not Now',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFA342FF), Color(0xFFE54D60)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text(
                  'Grant Permission',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}