import 'package:equatable/equatable.dart';

enum OnboardStatus {
  initial,
  profileCreated,
  categorySelected,
  brandSelected,
  completed,
}

enum AgentApprovalStatus {
  pending,
  approved,
  rejected,
}

class HushhAgent extends Equatable {
  final String id;
  final String agentId;
  final String phone;
  final String? email;
  final String? name;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? countryCode;
  final String? agentProfileImage;
  final String? selectedReasonForUsingHushh;
  final OnboardStatus onboardStatus;
  final AgentApprovalStatus agentApprovalStatus;
  final String? selectedCategoryId;
  final String? selectedBrandId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HushhAgent({
    required this.id,
    required this.agentId,
    required this.phone,
    this.email,
    this.name,
    this.fullName,
    this.firstName,
    this.lastName,
    this.countryCode,
    this.agentProfileImage,
    this.selectedReasonForUsingHushh,
    this.onboardStatus = OnboardStatus.initial,
    this.agentApprovalStatus = AgentApprovalStatus.pending,
    this.selectedCategoryId,
    this.selectedBrandId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties
  String get displayName => name ?? "${firstName ?? ""} ${lastName ?? ""}".trim();
  String get phoneNumberWithCountryCode => "+${countryCode?.replaceAll('+', '') ?? ""}$phone";
  bool get isProfileComplete => onboardStatus == OnboardStatus.completed;

  @override
  List<Object?> get props => [
        id,
        agentId,
        phone,
        email,
        name,
        fullName,
        firstName,
        lastName,
        countryCode,
        agentProfileImage,
        selectedReasonForUsingHushh,
        onboardStatus,
        agentApprovalStatus,
        selectedCategoryId,
        selectedBrandId,
        isActive,
        createdAt,
        updatedAt,
      ];
} 