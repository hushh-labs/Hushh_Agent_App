import '../../domain/entities/agent_card.dart';

/// Agent Card model for data layer operations
class AgentCardModel extends AgentCard {
  const AgentCardModel({
    required super.id,
    required super.agentId,
    super.email,
    super.fullName,
    super.videoUrl,
    super.businessName,
    super.businessType,
    super.location,
    super.phoneNumber,
    super.profileImageUrl,
    super.specializations,
    super.createdAt,
    super.updatedAt,
    super.isActive,
  });

  /// Create AgentCardModel from JSON map
  factory AgentCardModel.fromJson(Map<String, dynamic> json) {
    return AgentCardModel(
      id: json['id'] as String,
      agentId: json['agentId'] as String,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      videoUrl: json['videoUrl'] as String?,
      businessName: json['businessName'] as String?,
      businessType: json['businessType'] as String?,
      location: json['location'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      specializations: json['specializations'] != null
          ? List<String>.from(json['specializations'] as List)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Create AgentCardModel from AgentCard entity
  factory AgentCardModel.fromEntity(AgentCard agentCard) {
    return AgentCardModel(
      id: agentCard.id,
      agentId: agentCard.agentId,
      email: agentCard.email,
      fullName: agentCard.fullName,
      videoUrl: agentCard.videoUrl,
      businessName: agentCard.businessName,
      businessType: agentCard.businessType,
      location: agentCard.location,
      phoneNumber: agentCard.phoneNumber,
      profileImageUrl: agentCard.profileImageUrl,
      specializations: agentCard.specializations,
      createdAt: agentCard.createdAt,
      updatedAt: agentCard.updatedAt,
      isActive: agentCard.isActive,
    );
  }

  @override
  AgentCardModel copyWith({
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
    return AgentCardModel(
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
}