import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/agent_profile.dart';

/// Data model for AgentProfile with JSON serialization
class AgentProfileModel extends AgentProfile {
  const AgentProfileModel({
    required super.agentId,
    required super.email,
    super.displayName,
    super.phoneNumber,
    super.profilePictureUrl,
    required super.verificationStatus,
    required super.isActive,
    required super.isOnline,
    required super.createdAt,
    super.updatedAt,
    required super.hasCompletedOnboarding,
    required super.hasCompletedBusinessSetup,
    super.fcmToken,
    super.lastLoginAt,
    super.businessInfo,
  });

  /// Create from JSON Map
  factory AgentProfileModel.fromJson(Map<String, dynamic> json) {
    return AgentProfileModel(
      agentId: json['agentId'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      verificationStatus: AgentVerificationStatus.values.firstWhere(
        (e) => e.value == json['verificationStatus'],
        orElse: () => AgentVerificationStatus.pending,
      ),
      isActive: json['isActive'] as bool? ?? true,
      isOnline: json['isOnline'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      hasCompletedBusinessSetup: json['hasCompletedBusinessSetup'] as bool? ?? false,
      fcmToken: json['fcmToken'] as String?,
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      businessInfo: json['businessInfo'] as Map<String, dynamic>?,
    );
  }

  /// Create from Firestore document
  factory AgentProfileModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return AgentProfileModel(
      agentId: documentId,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      profilePictureUrl: data['profilePictureUrl'] as String?,
      verificationStatus: AgentVerificationStatus.values.firstWhere(
        (e) => e.value == data['verificationStatus'],
        orElse: () => AgentVerificationStatus.pending,
      ),
      isActive: data['isActive'] as bool? ?? true,
      isOnline: data['isOnline'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      hasCompletedOnboarding: data['hasCompletedOnboarding'] as bool? ?? false,
      hasCompletedBusinessSetup: data['hasCompletedBusinessSetup'] as bool? ?? false,
      fcmToken: data['fcmToken'] as String?,
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      businessInfo: data['businessInfo'] as Map<String, dynamic>?,
    );
  }

  /// Create from JSON String
  factory AgentProfileModel.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return AgentProfileModel.fromJson(json);
  }

  /// Convert to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'agentId': agentId,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
      'verificationStatus': verificationStatus.value,
      'isActive': isActive,
      'isOnline': isOnline,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'hasCompletedBusinessSetup': hasCompletedBusinessSetup,
      'fcmToken': fcmToken,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'businessInfo': businessInfo,
    };
  }

  /// Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
      'verificationStatus': verificationStatus.value,
      'isActive': isActive,
      'isOnline': isOnline,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'hasCompletedBusinessSetup': hasCompletedBusinessSetup,
      'fcmToken': fcmToken,
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'businessInfo': businessInfo,
    };
  }

  /// Convert to JSON String
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Convert to domain entity
  AgentProfile toEntity() {
    return AgentProfile(
      agentId: agentId,
      email: email,
      displayName: displayName,
      phoneNumber: phoneNumber,
      profilePictureUrl: profilePictureUrl,
      verificationStatus: verificationStatus,
      isActive: isActive,
      isOnline: isOnline,
      createdAt: createdAt,
      updatedAt: updatedAt,
      hasCompletedOnboarding: hasCompletedOnboarding,
      hasCompletedBusinessSetup: hasCompletedBusinessSetup,
      fcmToken: fcmToken,
      lastLoginAt: lastLoginAt,
      businessInfo: businessInfo,
    );
  }
} 