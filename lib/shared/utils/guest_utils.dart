import 'package:flutter/material.dart';
import 'app_local_storage.dart';
import '../core/components/guest_access_control.dart';

class GuestUtils {
  /// Check if user is in guest mode
  static bool get isGuestMode => AppLocalStorage.isGuestMode;

  /// Show sign-in required dialog for guest users
  /// Returns true if action should proceed (not in guest mode)
  /// Returns false if dialog was shown (guest mode)
  static bool checkGuestAccess(BuildContext context, String featureName) {
    // Use the comprehensive GuestAccessControl system
    return GuestAccessControl.checkFeatureAccess(context, featureName);
  }

  /// Show the guest sign-in dialog
  /// @deprecated Use GuestAccessControl.showGuestAccessPopup instead
  static void showGuestSignInDialog(BuildContext context, String featureName) {
    // Redirect to the new comprehensive guest access control
    GuestAccessControl.showGuestAccessPopup(context, featureName: featureName);
  }

  /// Wrapper function to execute action only if not in guest mode
  static void executeWithGuestCheck(
    BuildContext context,
    String featureName,
    VoidCallback action,
  ) {
    // Use the comprehensive GuestAccessControl system
    GuestAccessControl.executeWithAccessCheck(context, featureName, action);
  }
}
