import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppLocalStorage {
  static const String _guestModeKey = 'guest_mode';
  static const String _guestModeTypeKey = 'guest_mode_type';
  static const String _userTypeKey = 'user_type';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userPhoneKey = 'user_phone';
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _themeKey = 'theme';
  static const String _languageKey = 'language';

  // Guest mode management - check Firebase auth state
  static bool get isGuestMode {
    // Check if user is authenticated with Firebase
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser == null;
  }

  // Guest mode type (user/agent)
  static String get guestModeType {
    // For now, default to 'user' - can be enhanced to detect agent mode
    return 'user';
  }

  static Future<void> setGuestModeType(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_guestModeTypeKey, value);
  }

  // User type (user/agent) for registered users
  static String get userType {
    // For now, default to 'user' - can be enhanced based on user profile
    return 'user';
  }

  static Future<void> setUserType(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTypeKey, value);
  }

  // Feature access control for guest users
  static bool canAccessFeature(String feature) {
    if (!isGuestMode) return true; // Registered users have full access

    final guestType = guestModeType;
    
    // Features available for all guest users
    final allowedGuestFeatures = [
      'discover',
      'basic_settings',
      'terms_privacy',
      'app_info',
      'theme_options',
      'basic_permissions',
      'feedback',
      'basic_wallet',
      'notification',
      'location',
      'camera',
    ];

    // Additional features for guest agents
    final allowedAgentFeatures = [
      'basic_chat',
      'qr_scanner',
      'new_customers',
      'agent_dashboard',
    ];

    // Check base guest access
    if (allowedGuestFeatures.contains(feature)) {
      return true;
    }

    // Check agent-specific access
    if (guestType == 'agent' && allowedAgentFeatures.contains(feature)) {
      return true;
    }

    return false; // Feature is restricted for guests
  }

  // Get restricted features for current guest type
  static List<String> get restrictedGuestFeatures {
    if (!isGuestMode) return []; // No restrictions for registered users

    final guestType = guestModeType;
    
    final restrictedUserFeatures = [
      'contact',
      'media',
      'microphone',
      'pda',
      'receipts',
      'chat',
      'cart',
      'full_wallet',
      'notifications',
      'profile',
      'cards_data',
      'add_to_cart',
      'follow_post_like',
      'upgrade',
      'agent_profile',
      'marketplace',
    ];

    final restrictedAgentFeatures = [
      'contact',
      'media',
      'microphone',
      'full_chat_features',
      'marketplace_access',
    ];

    return guestType == 'agent' ? restrictedAgentFeatures : restrictedUserFeatures;
  }

  static Future<void> setGuestMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestModeKey, value);
  }

  // User data management
  static String? get userId {
    // Get current user ID from Firebase
    return FirebaseAuth.instance.currentUser?.uid;
  }

  static Future<void> setUserId(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setString(_userIdKey, value);
    } else {
      await prefs.remove(_userIdKey);
    }
  }

  static String? get userEmail {
    // Get current user email from Firebase
    return FirebaseAuth.instance.currentUser?.email;
  }

  static Future<void> setUserEmail(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setString(_userEmailKey, value);
    } else {
      await prefs.remove(_userEmailKey);
    }
  }

  static String? get userPhone {
    // Get current user phone from Firebase
    return FirebaseAuth.instance.currentUser?.phoneNumber;
  }

  static Future<void> setUserPhone(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setString(_userPhoneKey, value);
    } else {
      await prefs.remove(_userPhoneKey);
    }
  }

  // App settings
  static bool get isFirstLaunch {
    // For now, return true as default
    return true;
  }

  static Future<void> setFirstLaunch(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstLaunchKey, value);
  }

  static String get theme {
    // For now, return 'system' as default
    return 'system';
  }

  static Future<void> setTheme(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, value);
  }

  static String get language {
    // For now, return 'en' as default
    return 'en';
  }

  static Future<void> setLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, value);
  }

  // Clear all data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Clear user data only
  static Future<void> clearUserData() async {
    await setUserId(null);
    await setUserEmail(null);
    await setUserPhone(null);
  }

  // Helper methods for async operations
  static Future<String?> getStringAsync(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<bool> getBoolAsync(
    String key, {
    bool defaultValue = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  static Future<void> setStringAsync(String key, String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value != null) {
      await prefs.setString(key, value);
    } else {
      await prefs.remove(key);
    }
  }

  static Future<void> setBoolAsync(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}
