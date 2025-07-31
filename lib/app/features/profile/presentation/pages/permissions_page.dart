import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  Map<Permission, PermissionStatus> permissionStatuses = {};
  bool isLoading = true;

  final List<PermissionInfo> appPermissions = [
    PermissionInfo(
      permission: Permission.camera,
      title: 'Camera',
      description: 'Take photos and record videos for profile and content',
      icon: Icons.camera_alt,
    ),
    PermissionInfo(
      permission: Permission.photos,
      title: 'Photos',
      description: 'Access your photo library to upload images',
      icon: Icons.photo_library,
    ),
    PermissionInfo(
      permission: Permission.notification,
      title: 'Notifications',
      description: 'Send you important updates and alerts',
      icon: Icons.notifications,
    ),
    PermissionInfo(
      permission: Permission.location,
      title: 'Location',
      description: 'Show location-based features and nearby services',
      icon: Icons.location_on,
    ),
    PermissionInfo(
      permission: Permission.microphone,
      title: 'Microphone',
      description: 'Record audio for voice messages and video content',
      icon: Icons.mic,
    ),
    PermissionInfo(
      permission: Permission.contacts,
      title: 'Contacts',
      description: 'Find friends and colleagues using the app',
      icon: Icons.contacts,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadPermissionStatuses();
  }

  Future<void> _loadPermissionStatuses() async {
    setState(() {
      isLoading = true;
    });

    Map<Permission, PermissionStatus> statuses = {};

    for (final permissionInfo in appPermissions) {
      final status = await permissionInfo.permission.status;
      statuses[permissionInfo.permission] = status;
    }

    setState(() {
      permissionStatuses = statuses;
      isLoading = false;
    });
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      permissionStatuses[permission] = status;
    });

    if (status.isPermanentlyDenied) {
      _showSettingsDialog(permission);
    }
  }

  void _showSettingsDialog(Permission permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          'This permission has been permanently denied. Please enable it in your device settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Permissions',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA342FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.security,
                              color: Color(0xFFA342FF),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'App Permissions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Control what the app can access on your device. You can change these permissions anytime.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Permissions list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: appPermissions.length,
                    itemBuilder: (context, index) {
                      final permissionInfo = appPermissions[index];
                      final status =
                          permissionStatuses[permissionInfo.permission];

                      return _buildPermissionTile(permissionInfo, status);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPermissionTile(
      PermissionInfo permissionInfo, PermissionStatus? status) {
    final isGranted = status?.isGranted ?? false;
    final isDenied = status?.isDenied ?? false;
    final isPermanentlyDenied = status?.isPermanentlyDenied ?? false;

    Color statusColor = Colors.grey;
    String statusText = 'Unknown';
    IconData statusIcon = Icons.help_outline;

    if (isGranted) {
      statusColor = Colors.green;
      statusText = 'Granted';
      statusIcon = Icons.check_circle;
    } else if (isPermanentlyDenied) {
      statusColor = Colors.red;
      statusText = 'Denied';
      statusIcon = Icons.block;
    } else if (isDenied) {
      statusColor = Colors.orange;
      statusText = 'Not granted';
      statusIcon = Icons.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: isGranted
            ? null
            : () => _requestPermission(permissionInfo.permission),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Permission icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFA342FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  permissionInfo.icon,
                  color: const Color(0xFFA342FF),
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Permission details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      permissionInfo.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      permissionInfo.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          statusIcon,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action button or status
              if (!isGranted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA342FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isPermanentlyDenied ? 'Settings' : 'Grant',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA342FF),
                    ),
                  ),
                )
              else
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PermissionInfo {
  final Permission permission;
  final String title;
  final String description;
  final IconData icon;

  PermissionInfo({
    required this.permission,
    required this.title,
    required this.description,
    required this.icon,
  });
}
