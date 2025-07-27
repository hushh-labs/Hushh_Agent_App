import 'package:equatable/equatable.dart';

/// Base class for all splash screen events
abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the app during splash screen
class SplashInitializeEvent extends SplashEvent {
  const SplashInitializeEvent();
}

/// Event to check authentication status
class SplashCheckAuthEvent extends SplashEvent {
  const SplashCheckAuthEvent();
}

/// Event to load agent profile
class SplashLoadAgentProfileEvent extends SplashEvent {
  final String agentId;

  const SplashLoadAgentProfileEvent(this.agentId);

  @override
  List<Object?> get props => [agentId];
}

/// Event to update FCM token
class SplashUpdateFCMTokenEvent extends SplashEvent {
  final String agentId;
  final String fcmToken;

  const SplashUpdateFCMTokenEvent({
    required this.agentId,
    required this.fcmToken,
  });

  @override
  List<Object?> get props => [agentId, fcmToken];
}

/// Event to complete initialization and navigate
class SplashCompleteInitializationEvent extends SplashEvent {
  const SplashCompleteInitializationEvent();
}

/// Event to retry initialization after error
class SplashRetryInitializationEvent extends SplashEvent {
  const SplashRetryInitializationEvent();
}

/// Event to check permissions
class SplashCheckPermissionsEvent extends SplashEvent {
  const SplashCheckPermissionsEvent();
}

/// Event when splash animation completes
class SplashAnimationCompleteEvent extends SplashEvent {
  const SplashAnimationCompleteEvent();
}

/// Event to setup notifications
class SplashSetupNotificationsEvent extends SplashEvent {
  const SplashSetupNotificationsEvent();
}

/// Event to initialize analytics
class SplashInitializeAnalyticsEvent extends SplashEvent {
  final String agentId;

  const SplashInitializeAnalyticsEvent(this.agentId);

  @override
  List<Object?> get props => [agentId];
}

/// Event to load essential business data
class SplashLoadBusinessDataEvent extends SplashEvent {
  final String agentId;

  const SplashLoadBusinessDataEvent(this.agentId);

  @override
  List<Object?> get props => [agentId];
}

/// Event when initialization encounters an error
class SplashInitializationErrorEvent extends SplashEvent {
  final String error;

  const SplashInitializationErrorEvent(this.error);

  @override
  List<Object?> get props => [error];
} 