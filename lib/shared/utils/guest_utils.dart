import 'package:flutter/material.dart';
import '../constants/app_routes.dart';
import 'app_local_storage.dart';

class GuestUtils {
  /// Check if user is in guest mode
  static bool get isGuestMode => AppLocalStorage.isGuestMode;

  /// Show sign-in required dialog for guest users
  /// Returns true if action should proceed (not in guest mode)
  /// Returns false if dialog was shown (guest mode)
  static bool checkGuestAccess(BuildContext context, String featureName) {
    if (!isGuestMode) {
      return true; // User is authenticated, allow action
    }

    // User is in guest mode, show sign-in dialog
    showGuestSignInDialog(context, featureName);
    return false; // Block the action
  }

  /// Show the guest sign-in dialog
  static void showGuestSignInDialog(BuildContext context, String featureName) {
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFA342FF).withOpacity(0.2),
                      const Color(0xFFE54D60).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFA342FF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFFA342FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Sign In Required',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign in to unlock $featureName and access all features.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFA342FF),
                            Color(0xFFE54D60),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_outline,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Get full access to all premium features',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
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
                'Maybe Later',
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
                  // Navigate to main auth page
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.mainAuth,
                    (route) => false,
                  );
                },
                child: const Text(
                  'Sign In',
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

  /// Wrapper function to execute action only if not in guest mode
  static void executeWithGuestCheck(
    BuildContext context,
    String featureName,
    VoidCallback action,
  ) {
    if (checkGuestAccess(context, featureName)) {
      action();
    }
  }
}
