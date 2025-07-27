import '../entities/agent_profile.dart';
import '../entities/initialization_result.dart';
import '../repositories/splash_repository.dart';
import '../../../../../shared/core/use_cases/usecase.dart';

/// Main use case for initializing the app during splash screen
class InitializeAppUseCase implements UseCase<InitializationResult, NoParams> {
  final SplashRepository repository;

  InitializeAppUseCase(this.repository);

  @override
  Future<InitializationResult> call(NoParams params) async {
    try {
      // Step 1: Initialize core app services
      final initResult = await repository.initializeAppServices();
      if (!initResult.isSuccess) {
        return initResult;
      }

      // Step 2: Check authentication status
      final isAuthenticated = await repository.isAgentAuthenticated();
      if (!isAuthenticated) {
        return InitializationResult.noAgent();
      }

      // Step 3: Get agent profile
      final agentProfile = await repository.getCurrentAgentProfile();
      if (agentProfile == null) {
        return InitializationResult.failure(
          errorMessage: 'Failed to load agent profile',
        );
      }

      // Step 4: Check and request permissions
      await repository.checkAndRequestPermissions();

      // Step 5: Update FCM token for notifications
      if (agentProfile.fcmToken?.isNotEmpty == true) {
        await repository.updateAgentFCMToken(
          agentProfile.agentId,
          agentProfile.fcmToken!,
        );
      }

      // Step 6: Update last login timestamp
      await repository.updateLastLoginTimestamp(agentProfile.agentId);

      // Step 7: Initialize analytics
      await repository.initializeAnalytics(agentProfile.agentId);

      // Step 8: Load essential business data
      await repository.loadEssentialBusinessData(agentProfile.agentId);

      // Step 9: Determine next action based on agent state
      final nextAction = _determineNextAction(agentProfile);

      return InitializationResult.success(
        agentProfile: agentProfile,
        nextAction: nextAction,
      );
    } catch (e) {
      return InitializationResult.failure(
        errorMessage: 'Initialization failed: ${e.toString()}',
      );
    }
  }

  /// Business logic to determine where agent should go next
  NextAction _determineNextAction(AgentProfile agent) {
    // If agent is suspended, show error
    if (agent.verificationStatus.value == 'suspended') {
      return NextAction.showError;
    }

    // If agent hasn't completed onboarding
    if (agent.needsOnboarding) {
      return NextAction.navigateToOnboarding;
    }

    // If agent hasn't completed business setup
    if (agent.needsBusinessSetup) {
      return NextAction.navigateToBusinessSetup;
    }

    // If agent is pending verification
    if (agent.needsVerification) {
      return NextAction.navigateToVerification;
    }

    // If agent can access dashboard
    if (agent.canAccessDashboard) {
      return NextAction.navigateToDashboard;
    }

    // Default fallback
    return NextAction.navigateToAuth;
  }
} 