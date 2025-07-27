import '../../domain/entities/agent_profile.dart';
import '../../domain/entities/initialization_result.dart';
import '../../domain/repositories/splash_repository.dart';
import '../datasources/splash_local_data_source.dart';
import '../datasources/splash_remote_data_source.dart';

/// Implementation of SplashRepository
/// Coordinates between local and remote data sources
class SplashRepositoryImpl implements SplashRepository {
  final SplashLocalDataSource localDataSource;
  final SplashRemoteDataSource remoteDataSource;

  SplashRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<bool> isAgentAuthenticated() async {
    try {
      // Check local authentication first (faster)
      final isLocalAuth = await localDataSource.isAuthenticated();
      
      if (isLocalAuth) {
        // Verify we have a valid agent ID
        final agentId = await localDataSource.getCurrentAgentId();
        return agentId?.isNotEmpty == true;
      }
      
      return false;
    } catch (e) {
      print('❌ [REPO] Error checking authentication: $e');
      return false;
    }
  }

  @override
  Future<AgentProfile?> getCurrentAgentProfile() async {
    try {
      // Try to get from cache first
      final cachedProfile = await localDataSource.getCachedAgentProfile();
      if (cachedProfile != null) {
        print('✅ [REPO] Got agent profile from cache');
        return cachedProfile.toEntity();
      }

      // If not in cache, get current agent ID and fetch from remote
      final agentId = await localDataSource.getCurrentAgentId();
      if (agentId?.isNotEmpty == true) {
        final remoteProfile = await remoteDataSource.getAgentProfile(agentId!);
        if (remoteProfile != null) {
          // Cache the profile for next time
          await localDataSource.cacheAgentProfile(remoteProfile);
          print('✅ [REPO] Got agent profile from remote and cached');
          return remoteProfile.toEntity();
        }
      }

      return null;
    } catch (e) {
      print('❌ [REPO] Error getting agent profile: $e');
      return null;
    }
  }

  @override
  Future<InitializationResult> initializeAppServices() async {
    try {
      // Initialize Firebase and core services
      final firebaseInitialized = await remoteDataSource.initializeFirebase();
      if (!firebaseInitialized) {
        return InitializationResult.failure(
          errorMessage: 'Failed to initialize Firebase services',
        );
      }

      // Setup notifications
      await remoteDataSource.setupNotifications();

      print('✅ [REPO] App services initialized successfully');
      return InitializationResult.success(
        agentProfile: AgentProfile(
          agentId: '',
          email: '',
          verificationStatus: AgentVerificationStatus.pending,
          isActive: true,
          createdAt: DateTime.now(),
          hasCompletedOnboarding: false,
          hasCompletedBusinessSetup: false,
          isOnline: false,
        ),
        nextAction: NextAction.navigateToAuth,
      );
    } catch (e) {
      print('❌ [REPO] Error initializing app services: $e');
      return InitializationResult.failure(
        errorMessage: 'Failed to initialize app services: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateAgentFCMToken(String agentId, String fcmToken) async {
    try {
      // Update both local and remote
      await Future.wait([
        localDataSource.storeFCMToken(fcmToken),
        remoteDataSource.updateFCMToken(agentId, fcmToken),
      ]);
      print('✅ [REPO] FCM token updated');
    } catch (e) {
      print('❌ [REPO] Error updating FCM token: $e');
    }
  }

  @override
  Future<bool> checkAndRequestPermissions() async {
    try {
      // TODO: Implement permission checks
      // - Location permission
      // - Notification permission
      // - Camera permission (for business verification)
      // - Storage permission
      
      print('🔄 [REPO] Checking and requesting permissions');
      return true; // Default to true for now
    } catch (e) {
      print('❌ [REPO] Error checking permissions: $e');
      return false;
    }
  }

  @override
  Future<DateTime?> getLastLoginTimestamp(String agentId) async {
    try {
      return await localDataSource.getLastLoginTimestamp();
    } catch (e) {
      print('❌ [REPO] Error getting last login timestamp: $e');
      return null;
    }
  }

  @override
  Future<void> updateLastLoginTimestamp(String agentId) async {
    try {
      final now = DateTime.now();
      await Future.wait([
        localDataSource.storeLastLoginTimestamp(now),
        remoteDataSource.updateLastLoginTimestamp(agentId, now),
      ]);
      print('✅ [REPO] Last login timestamp updated');
    } catch (e) {
      print('❌ [REPO] Error updating last login timestamp: $e');
    }
  }

  @override
  Future<bool> needsOnboarding(String agentId) async {
    try {
      return !(await localDataSource.isOnboardingCompleted());
    } catch (e) {
      print('❌ [REPO] Error checking onboarding status: $e');
      return true; // Default to true if error
    }
  }

  @override
  Future<bool> needsBusinessSetup(String agentId) async {
    try {
      return !(await localDataSource.isBusinessSetupCompleted());
    } catch (e) {
      print('❌ [REPO] Error checking business setup status: $e');
      return true; // Default to true if error
    }
  }

  @override
  Future<String> getBusinessVerificationStatus(String agentId) async {
    try {
      return await remoteDataSource.getVerificationStatus(agentId);
    } catch (e) {
      print('❌ [REPO] Error getting verification status: $e');
      return 'pending';
    }
  }

  @override
  Future<void> clearCachedData() async {
    try {
      await localDataSource.clearAllData();
      print('✅ [REPO] All cached data cleared');
    } catch (e) {
      print('❌ [REPO] Error clearing cached data: $e');
    }
  }

  @override
  Future<bool> checkForAppUpdates() async {
    try {
      return await remoteDataSource.checkAppUpdates();
    } catch (e) {
      print('❌ [REPO] Error checking app updates: $e');
      return false;
    }
  }

  @override
  Future<void> initializeAnalytics(String agentId) async {
    try {
      await remoteDataSource.initializeAnalytics(agentId);
      print('✅ [REPO] Analytics initialized');
    } catch (e) {
      print('❌ [REPO] Error initializing analytics: $e');
    }
  }

  @override
  Future<void> setupGeofencingServices() async {
    try {
      // TODO: Implement geofencing setup
      print('🔄 [REPO] Setting up geofencing services');
    } catch (e) {
      print('❌ [REPO] Error setting up geofencing: $e');
    }
  }

  @override
  Future<void> loadEssentialBusinessData(String agentId) async {
    try {
      await remoteDataSource.loadBusinessData(agentId);
      print('✅ [REPO] Essential business data loaded');
    } catch (e) {
      print('❌ [REPO] Error loading business data: $e');
    }
  }
} 