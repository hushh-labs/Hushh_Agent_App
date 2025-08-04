import 'package:flutter/material.dart';
import '../../constants/app_routes.dart';
import '../../utils/app_local_storage.dart';

/// Comprehensive guest access control system for the Hushh App
/// Handles differentiated permissions for guest users vs registered users
class GuestAccessControl {
  /// Check if user can access a specific feature
  /// Returns true if action should proceed
  /// Returns false if dialog was shown (guest mode restriction)
  static bool checkFeatureAccess(BuildContext context, String featureName) {
    if (!AppLocalStorage.isGuestMode) {
      return true; // User is authenticated, allow action
    }

    // Check if feature is allowed for current guest type
    if (AppLocalStorage.canAccessFeature(featureName)) {
      return true; // Feature is allowed for this guest type
    }

    // Feature is restricted, show appropriate dialog
    showGuestAccessPopup(context, featureName: featureName);
    return false; // Block the action
  }

  /// Show the comprehensive guest access dialog
  static void showGuestAccessPopup(BuildContext context, {String? featureName}) {
    final isAgentGuest = AppLocalStorage.guestModeType == 'agent';
    final guestType = isAgentGuest ? 'Agent' : 'User';
    
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
                  Icons.lock_outline,
                  color: Color(0xFFA342FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isAgentGuest ? 'Agent Feature Locked' : 'Feature Locked',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This feature is available to registered ${isAgentGuest ? 'agents' : 'users'}. Sign in to unlock premium features and get the full Hushh experience.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              
              // Feature name highlight
              if (featureName != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA342FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFA342FF).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Feature: ${featureName.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA342FF),
                    ),
                  ),
                ),
              ],
              
              // Available features section
              const SizedBox(height: 16),
              Text(
                'As a $guestType Guest, you can still:',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              
              // Available features list
              _buildAvailableFeatureItem(
                icon: Icons.explore_outlined,
                title: 'Explore & Discover',
                description: 'Browse content and discover new features',
              ),
              _buildAvailableFeatureItem(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Basic Wallet',
                description: 'View basic wallet information',
              ),
              _buildAvailableFeatureItem(
                icon: Icons.settings_outlined,
                title: 'App Settings',
                description: 'Customize your app experience',
              ),
              if (isAgentGuest) ...[
                _buildAvailableFeatureItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'Basic Chat',
                  description: 'Limited chat functionality',
                ),
                _buildAvailableFeatureItem(
                  icon: Icons.qr_code_scanner,
                  title: 'QR Scanner',
                  description: 'Scan QR codes for quick access',
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to home to explore available features
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
              child: Text(
                'Explore Available Features',
                style: TextStyle(
                  color: Colors.grey[600],
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
                  // Clear guest mode and navigate to auth
                  AppLocalStorage.setGuestMode(false);
                  Navigator.pushReplacementNamed(context, AppRoutes.mainAuth);
                },
                child: Text(
                  isAgentGuest ? 'Sign In as Agent' : 'Sign In / Sign Up',
                  style: const TextStyle(
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

  /// Build an available feature item for the dialog
  static Widget _buildAvailableFeatureItem({
    required IconData icon,
    required String title,
    String? description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: Colors.green,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (description != null)
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Show a simplified permission blocked dialog
  static void showPermissionBlockedDialog(BuildContext context, String permissionName) {
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
                  Icons.security,
                  color: Color(0xFFA342FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Premium Permission',
                  style: TextStyle(
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
                'Access to $permissionName requires a full account. Sign in to unlock all permissions and premium features.',
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
                  color: const Color(0xFFA342FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_outline,
                      color: Color(0xFFA342FF),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'PRO: $permissionName Access',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFA342FF),
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
              child: Text(
                'Maybe Later',
                style: TextStyle(
                  color: Colors.grey[600],
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
                  AppLocalStorage.setGuestMode(false);
                  Navigator.pushReplacementNamed(context, AppRoutes.mainAuth);
                },
                child: const Text(
                  'Sign In / Sign Up',
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

  /// Wrapper function to execute action only if feature access is allowed
  static void executeWithAccessCheck(
    BuildContext context,
    String featureName,
    VoidCallback action,
  ) {
    if (checkFeatureAccess(context, featureName)) {
      action();
    }
  }

  /// Get user-friendly feature name for display
  static String getFeatureDisplayName(String featureName) {
    switch (featureName) {
      case 'contact':
        return 'Contacts Access';
      case 'media':
        return 'Media Access';
      case 'microphone':
        return 'Microphone Access';
      case 'pda':
        return 'Personal Data Assistant';
      case 'receipts':
        return 'Receipt Management';
      case 'chat':
        return 'Full Chat Features';
      case 'cart':
        return 'Shopping Cart';
      case 'full_wallet':
        return 'Complete Wallet';
      case 'profile':
        return 'User Profile';
      case 'cards_data':
        return 'Cards & Data';
      case 'add_to_cart':
        return 'Add to Cart';
      case 'follow_post_like':
        return 'Social Features';
      case 'upgrade':
        return 'Premium Upgrade';
      case 'agent_profile':
        return 'Agent Profile';
      case 'marketplace':
        return 'Marketplace Access';
      default:
        return featureName.replaceAll('_', ' ').toUpperCase();
    }
  }
}