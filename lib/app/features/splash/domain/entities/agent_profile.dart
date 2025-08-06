import 'package:equatable/equatable.dart';

/// Enum for agent verification status
enum AgentVerificationStatus {
  pending,
  verified,
  rejected,
  suspended;

  String get value => name;
}

/// Entity representing an agent's profile
class AgentProfile extends Equatable {
  final String agentId;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final AgentVerificationStatus verificationStatus;
  final bool isActive;
  final bool isOnline;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool hasCompletedOnboarding;
  final bool hasCompletedBusinessSetup;
  final String? fcmToken;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? businessInfo;

  const AgentProfile({
    required this.agentId,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.profilePictureUrl,
    required this.verificationStatus,
    required this.isActive,
    required this.isOnline,
    required this.createdAt,
    this.updatedAt,
    required this.hasCompletedOnboarding,
    required this.hasCompletedBusinessSetup,
    this.fcmToken,
    this.lastLoginAt,
    this.businessInfo,
  });

  /// Check if agent needs onboarding
  bool get needsOnboarding => !hasCompletedOnboarding;

  /// Check if agent needs business setup
  bool get needsBusinessSetup => !hasCompletedBusinessSetup && hasCompletedOnboarding;

  /// Check if agent needs verification
  bool get needsVerification => verificationStatus == AgentVerificationStatus.pending;

  /// Check if agent can access dashboard
  bool get canAccessDashboard => 
      hasCompletedOnboarding && 
      hasCompletedBusinessSetup && 
      verificationStatus == AgentVerificationStatus.verified &&
      isActive;

  @override
  List<Object?> get props => [
        agentId,
        email,
        displayName,
        phoneNumber,
        profilePictureUrl,
        verificationStatus,
        isActive,
        isOnline,
        createdAt,
        updatedAt,
        hasCompletedOnboarding,
        hasCompletedBusinessSetup,
        fcmToken,
        lastLoginAt,
        businessInfo,
      ];
} 