import 'package:equatable/equatable.dart';
import '../../domain/entities/agent_profile.dart';
import '../../domain/entities/initialization_result.dart';

/// Base class for all splash screen states
abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// Initial state when splash screen starts
class SplashInitialState extends SplashState {
  const SplashInitialState();
}

/// State when initialization is in progress
class SplashInitializingState extends SplashState {
  final String message;
  final double progress;

  const SplashInitializingState({
    required this.message,
    this.progress = 0.0,
  });

  @override
  List<Object?> get props => [message, progress];
}

/// State when checking authentication
class SplashCheckingAuthState extends SplashState {
  const SplashCheckingAuthState();
}

/// State when loading agent profile
class SplashLoadingProfileState extends SplashState {
  const SplashLoadingProfileState();
}

/// State when setting up notifications
class SplashSetupNotificationsState extends SplashState {
  const SplashSetupNotificationsState();
}

/// State when checking permissions
class SplashCheckingPermissionsState extends SplashState {
  const SplashCheckingPermissionsState();
}

/// State when initializing analytics
class SplashInitializingAnalyticsState extends SplashState {
  const SplashInitializingAnalyticsState();
}

/// State when loading business data
class SplashLoadingBusinessDataState extends SplashState {
  const SplashLoadingBusinessDataState();
}

/// State when initialization is completed successfully
class SplashInitializationCompleteState extends SplashState {
  final AgentProfile? agentProfile;
  final NextAction nextAction;

  const SplashInitializationCompleteState({
    this.agentProfile,
    required this.nextAction,
  });

  @override
  List<Object?> get props => [agentProfile, nextAction];
}

/// State when initialization fails
class SplashInitializationErrorState extends SplashState {
  final String errorMessage;
  final bool canRetry;

  const SplashInitializationErrorState({
    required this.errorMessage,
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [errorMessage, canRetry];
}

/// State when navigating to the next screen
class SplashNavigatingState extends SplashState {
  final NextAction nextAction;
  final AgentProfile? agentProfile;

  const SplashNavigatingState({
    required this.nextAction,
    this.agentProfile,
  });

  @override
  List<Object?> get props => [nextAction, agentProfile];
}

/// State when no agent is found (need to login)
class SplashNoAgentState extends SplashState {
  const SplashNoAgentState();
}

/// State when agent profile is loaded
class SplashAgentProfileLoadedState extends SplashState {
  final AgentProfile agentProfile;

  const SplashAgentProfileLoadedState(this.agentProfile);

  @override
  List<Object?> get props => [agentProfile];
}

/// State when agent needs onboarding
class SplashAgentNeedsOnboardingState extends SplashState {
  final AgentProfile agentProfile;

  const SplashAgentNeedsOnboardingState(this.agentProfile);

  @override
  List<Object?> get props => [agentProfile];
}

/// State when agent needs business setup
class SplashAgentNeedsBusinessSetupState extends SplashState {
  final AgentProfile agentProfile;

  const SplashAgentNeedsBusinessSetupState(this.agentProfile);

  @override
  List<Object?> get props => [agentProfile];
}

/// State when agent needs verification
class SplashAgentNeedsVerificationState extends SplashState {
  final AgentProfile agentProfile;

  const SplashAgentNeedsVerificationState(this.agentProfile);

  @override
  List<Object?> get props => [agentProfile];
}

/// State when agent can access dashboard
class SplashAgentCanAccessDashboardState extends SplashState {
  final AgentProfile agentProfile;

  const SplashAgentCanAccessDashboardState(this.agentProfile);

  @override
  List<Object?> get props => [agentProfile];
}

/// State when waiting for splash animation to complete
class SplashWaitingForAnimationState extends SplashState {
  final AgentProfile? agentProfile;
  final NextAction nextAction;

  const SplashWaitingForAnimationState({
    this.agentProfile,
    required this.nextAction,
  });

  @override
  List<Object?> get props => [agentProfile, nextAction];
} 