import 'package:shared_preferences/shared_preferences.dart';
import '../models/agent_profile_model.dart';

/// Abstract interface for local data operations
abstract class SplashLocalDataSource {
  Future<bool> isAuthenticated();
  Future<String?> getCurrentAgentId();
  Future<AgentProfileModel?> getCachedAgentProfile();
  Future<void> cacheAgentProfile(AgentProfileModel profile);
  Future<void> storeFCMToken(String token);
  Future<String?> getFCMToken();
  Future<DateTime?> getLastLoginTimestamp();
  Future<void> storeLastLoginTimestamp(DateTime timestamp);
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted(bool completed);
  Future<bool> isBusinessSetupCompleted();
  Future<void> setBusinessSetupCompleted(bool completed);
  Future<void> clearAllData();
}

/// Implementation of local data source using SharedPreferences
class SplashLocalDataSourceImpl implements SplashLocalDataSource {
  static const String _keyIsAuthenticated = 'is_authenticated';
  static const String _keyAgentId = 'agent_id';
  static const String _keyAgentProfile = 'agent_profile';
  static const String _keyFCMToken = 'fcm_token';
  static const String _keyLastLogin = 'last_login';
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyBusinessSetupCompleted = 'business_setup_completed';

  @override
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsAuthenticated) ?? false;
  }

  @override
  Future<String?> getCurrentAgentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAgentId);
  }

  @override
  Future<AgentProfileModel?> getCachedAgentProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_keyAgentProfile);
    if (profileJson != null) {
      return AgentProfileModel.fromJsonString(profileJson);
    }
    return null;
  }

  @override
  Future<void> cacheAgentProfile(AgentProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAgentProfile, profile.toJsonString());
    await prefs.setString(_keyAgentId, profile.agentId);
    await prefs.setBool(_keyIsAuthenticated, true);
  }

  @override
  Future<void> storeFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFCMToken, token);
  }

  @override
  Future<String?> getFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFCMToken);
  }

  @override
  Future<DateTime?> getLastLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_keyLastLogin);
    return timestamp != null 
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  @override
  Future<void> storeLastLoginTimestamp(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastLogin, timestamp.millisecondsSinceEpoch);
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, completed);
  }

  @override
  Future<bool> isBusinessSetupCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBusinessSetupCompleted) ?? false;
  }

  @override
  Future<void> setBusinessSetupCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBusinessSetupCompleted, completed);
  }

  @override
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
} 