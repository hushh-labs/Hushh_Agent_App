import '../entities/agent_profile.dart';
import '../entities/initialization_result.dart';

/// Repository interface for splash screen operations
/// This defines the contract that data layer must implement
abstract class SplashRepository {
  /// Check if agent is currently authenticated
  Future<bool> isAgentAuthenticated();

  /// Get current agent profile from cache or remote
  Future<AgentProfile?> getCurrentAgentProfile();

  /// Initialize app services (Firebase, notifications, etc.)
  Future<InitializationResult> initializeAppServices();

  /// Update agent's FCM token for push notifications
  Future<void> updateAgentFCMToken(String agentId, String fcmToken);

  /// Check and request necessary permissions
  Future<bool> checkAndRequestPermissions();

  /// Get agent's last login timestamp
  Future<DateTime?> getLastLoginTimestamp(String agentId);

  /// Update agent's last login timestamp
  Future<void> updateLastLoginTimestamp(String agentId);

  /// Check if agent needs to complete onboarding
  Future<bool> needsOnboarding(String agentId);

  /// Check if agent needs to complete business setup
  Future<bool> needsBusinessSetup(String agentId);

  /// Get agent's business verification status
  Future<String> getBusinessVerificationStatus(String agentId);

  /// Clear all cached data (for logout)
  Future<void> clearCachedData();

  /// Check for app updates
  Future<bool> checkForAppUpdates();

  /// Initialize analytics tracking
  Future<void> initializeAnalytics(String agentId);

  /// Setup geofencing services (if needed)
  Future<void> setupGeofencingServices();

  /// Load essential business data
  Future<void> loadEssentialBusinessData(String agentId);
} 