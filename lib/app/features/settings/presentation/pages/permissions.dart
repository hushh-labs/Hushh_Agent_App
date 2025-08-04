import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../shared/utils/app_local_storage.dart';
import '../../../../../shared/core/components/guest_access_control.dart';

/// Main permissions management page implementing comprehensive permission system
class PermissionsView extends StatefulWidget {
  const PermissionsView({super.key});

  @override
  State<PermissionsView> createState() => _PermissionsViewState();
}

class _PermissionsViewState extends State<PermissionsView> {
  // Boolean status for UI display
  final Map<String, bool> permissionStatuses = {
    'notification': false,
    'contact': false,
    'location': false,
    'camera': false,
    'media': false,
    'microphone': false,
  };

  // Detailed permission states for logic
  final Map<String, PermissionStatus> permissionStates = {
    'notification': PermissionStatus.denied,
    'contact': PermissionStatus.denied,
    'location': PermissionStatus.denied,
    'camera': PermissionStatus.denied,
    'media': PermissionStatus.denied,
    'microphone': PermissionStatus.denied,
  };

  bool allPermissionsGranted = false;

  // Flutter Local Notifications Plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();



  @override
  void initState() {
    super.initState();
    _initializePermissionStatuses();
  }

  /// Initialize all permission statuses
  Future<void> _initializePermissionStatuses() async {
    // Check individual permissions
    permissionStatuses['notification'] = await Permission.notification.isGranted;
    permissionStatuses['contact'] = await Permission.contacts.isGranted;
    
    // Location has multiple permission types to check
    permissionStatuses['location'] =
        (await Permission.locationWhenInUse.isGranted) ||
        (await Permission.locationAlways.isGranted) ||
        (await Permission.location.isGranted);
    
    permissionStatuses['camera'] = await Permission.camera.isGranted;
    permissionStatuses['media'] = await Permission.photos.isGranted;
    permissionStatuses['microphone'] = await Permission.microphone.isGranted;

    // Initialize detailed states for better handling
    permissionStates['notification'] = await Permission.notification.status;
    permissionStates['contact'] = await Permission.contacts.status;
    permissionStates['location'] = await Permission.locationWhenInUse.status;
    permissionStates['camera'] = await Permission.camera.status;
    permissionStates['media'] = await Permission.photos.status;
    permissionStates['microphone'] = await Permission.microphone.status;

    _checkAllPermissionStatuses();
    setState(() {});
  }

  /// Check if all permissions are granted
  void _checkAllPermissionStatuses() {
    allPermissionsGranted = permissionStatuses.values.every((status) => status);
  }

  /// Platform-specific notification permission initialization
  Future<void> _initializeNotificationPermission() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  /// Request specific permission
  Future<void> _requestPermission(Permission permission, String key) async {
    // Check current status first
    PermissionStatus currentStatus = await permission.status;

    // Handle permanently denied case
    if (currentStatus == PermissionStatus.permanentlyDenied) {
      _showPermissionExplanationDialog(key);
      return;
    }

    // Request permission
    PermissionStatus status = await permission.request();
    permissionStates[key] = status;

    // Handle result
    if (status == PermissionStatus.denied || 
        status == PermissionStatus.permanentlyDenied) {
      _showPermissionExplanationDialog(key);
    }

    // Update UI
    permissionStatuses[key] = status.isGranted;
    _checkAllPermissionStatuses();
    setState(() {});
  }

  /// Handle bulk permission toggle
  void _toggleAllPermissions(bool value) async {
    if (value) {
      // Request all permissions
      await _initializeNotificationPermission();
      await _requestPermission(Permission.contacts, 'contact');
      await _requestPermission(Permission.locationWhenInUse, 'location');
      await _requestPermission(Permission.camera, 'camera');
      await _requestPermission(Permission.photos, 'media');
      await _requestPermission(Permission.microphone, 'microphone');
    } else {
      // Show explanation for disabling permissions
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Disable Permissions'),
            content: const Text(
              'To disable all permissions, you\'ll need to go to your device settings and manually turn them off.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
    _checkAllPermissionStatuses();
  }

  /// Show permission explanation dialog
  void _showPermissionExplanationDialog(String key) {
    String title = '';
    String message = '';

    switch (key) {
      case 'notification':
        title = 'Notification Permission';
        message = 'Hushh uses notifications to keep you updated about new messages, card shares, and important updates. Enable notifications to stay connected.';
        break;
      case 'contact':
        title = 'Contacts Permission';
        message = 'Hushh needs access to your contacts to help you connect with people you know and share cards easily. Your contacts are kept private and secure.';
        break;
      case 'location':
        title = 'Location Permission';
        message = 'Hushh uses location access to provide location-based features, nearby services, and improve your experience with local content.';
        break;
      case 'camera':
        title = 'Camera Permission';
        message = 'Hushh needs camera access to take photos for your profile, scan QR codes, and capture images for sharing. Your photos remain private.';
        break;
      case 'media':
        title = 'Media Permission';
        message = 'Hushh needs access to your photo library to upload profile pictures, share images, and access media for your content.';
        break;
      case 'microphone':
        title = 'Microphone Permission';
        message = 'Hushh uses microphone access for voice input features, audio messages, and enhanced communication capabilities.';
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFA342FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFFA342FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            if (permissionStates[key] == PermissionStatus.permanentlyDenied)
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
                    openAppSettings();
                  },
                  child: const Text(
                    'Open Settings',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F7),
      appBar: AppBar(
        title: const Text(
          'App Access',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xffF2F2F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Introduction section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA342FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.security,
                      color: Color(0xFFA342FF),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Manage App Permissions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Control what Hushh can access on your device. We only request permissions that enhance your experience.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Master toggle
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Turn on all',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  CupertinoSwitch(
                    value: allPermissionsGranted,
                    onChanged: _toggleAllPermissions,
                    activeColor: const Color(0xFFA342FF),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Permission tiles
            _buildPermissionTile(
              title: 'Notifications',
              description: 'Stay updated with messages and alerts',
              key: 'notification',
              permission: Permission.notification,
              icon: Icons.notifications_outlined,
            ),

            _buildPermissionTile(
              title: 'Contacts',
              description: 'Connect with people you know',
              key: 'contact',
              permission: Permission.contacts,
              icon: Icons.people_outlined,
            ),

            _buildPermissionTile(
              title: 'Location',
              description: 'Location-based features and services',
              key: 'location',
              permission: Permission.locationWhenInUse,
              icon: Icons.location_on_outlined,
            ),

            _buildPermissionTile(
              title: 'Camera',
              description: 'Take photos and scan QR codes',
              key: 'camera',
              permission: Permission.camera,
              icon: Icons.camera_alt_outlined,
            ),

            _buildPermissionTile(
              title: 'Photos',
              description: 'Access your photo library',
              key: 'media',
              permission: Permission.photos,
              icon: Icons.photo_library_outlined,
            ),

            _buildPermissionTile(
              title: 'Microphone',
              description: 'Voice input and audio features',
              key: 'microphone',
              permission: Permission.microphone,
              icon: Icons.mic_outlined,
            ),

            const SizedBox(height: 20),

            // Footer info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can change these permissions anytime in your device settings.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual permission tile
  Widget _buildPermissionTile({
    required String title,
    required String description,
    required String key,
    required Permission permission,
    required IconData icon,
  }) {
    final isGranted = permissionStatuses[key] ?? false;
    final isRestrictedForGuest = AppLocalStorage.isGuestMode &&
        ['contact', 'media', 'microphone'].contains(key);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isRestrictedForGuest
            ? Border.all(color: const Color(0xFFA342FF).withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          // Icon container with status-based styling
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isRestrictedForGuest
                  ? const Color(0xFFA342FF).withOpacity(0.1)
                  : (isGranted
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isRestrictedForGuest
                  ? const Color(0xFFA342FF)
                  : (isGranted ? Colors.green : Colors.grey),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Title and description with Pro badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    if (isRestrictedForGuest) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA342FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFA342FF),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          
          // Permission toggle switch
          if (isRestrictedForGuest)
            CupertinoSwitch(
              value: false,
              onChanged: (value) {
                GuestAccessControl.showPermissionBlockedDialog(context, title);
              },
              activeColor: const Color(0xFFA342FF),
            )
          else
            CupertinoSwitch(
              value: isGranted,
              onChanged: (value) => _requestPermission(permission, key),
              activeColor: const Color(0xFFA342FF),
            ),
        ],
      ),
    );
  }
}