import 'package:equatable/equatable.dart';
import 'agent_profile.dart';

/// Enum for determining next action after initialization
enum NextAction {
  navigateToAuth,
  navigateToOnboarding,
  navigateToBusinessSetup,
  navigateToVerification,
  navigateToDashboard,
  showError,
}

/// Result of app initialization process
class InitializationResult extends Equatable {
  final bool isSuccess;
  final AgentProfile? agentProfile;
  final NextAction nextAction;
  final String? errorMessage;

  const InitializationResult({
    required this.isSuccess,
    this.agentProfile,
    required this.nextAction,
    this.errorMessage,
  });

  /// Factory constructor for successful initialization
  factory InitializationResult.success({
    required AgentProfile agentProfile,
    required NextAction nextAction,
  }) {
    return InitializationResult(
      isSuccess: true,
      agentProfile: agentProfile,
      nextAction: nextAction,
    );
  }

  /// Factory constructor for failed initialization
  factory InitializationResult.failure({
    required String errorMessage,
  }) {
    return InitializationResult(
      isSuccess: false,
      nextAction: NextAction.showError,
      errorMessage: errorMessage,
    );
  }

  /// Factory constructor for no agent found
  factory InitializationResult.noAgent() {
    return const InitializationResult(
      isSuccess: true,
      nextAction: NextAction.navigateToAuth,
    );
  }

  @override
  List<Object?> get props => [
        isSuccess,
        agentProfile,
        nextAction,
        errorMessage,
      ];
} 