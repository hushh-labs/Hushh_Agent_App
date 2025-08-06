import 'package:equatable/equatable.dart';

/// Agent Card entity representing an agent's digital card
class AgentCard extends Equatable {
  final String id;
  final String agentId;
  final String? email;
  final String? fullName;
  final String? videoUrl;
  final String? businessName;
  final String? businessType;
  final String? location;
  final String? phoneNumber;
  final String? profileImageUrl;
  final List<String>? specializations;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const AgentCard({
    required this.id,
    required this.agentId,
    this.email,
    this.fullName,
    this.videoUrl,
    this.businessName,
    this.businessType,
    this.location,
    this.phoneNumber,
    this.profileImageUrl,
    this.specializations,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  /// Create a copy of the agent card with updated fields
  AgentCard copyWith({
    String? id,
    String? agentId,
    String? email,
    String? fullName,
    String? videoUrl,
    String? businessName,
    String? businessType,
    String? location,
    String? phoneNumber,
    String? profileImageUrl,
    List<String>? specializations,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return AgentCard(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      videoUrl: videoUrl ?? this.videoUrl,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      location: location ?? this.location,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      specializations: specializations ?? this.specializations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentId': agentId,
      'email': email,
      'fullName': fullName,
      'videoUrl': videoUrl,
      'businessName': businessName,
      'businessType': businessType,
      'location': location,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'specializations': specializations,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        agentId,
        email,
        fullName,
        videoUrl,
        businessName,
        businessType,
        location,
        phoneNumber,
        profileImageUrl,
        specializations,
        createdAt,
        updatedAt,
        isActive,
      ];
}