import '../../domain/entities/agent_brand.dart';

class AgentBrandModel extends AgentBrand {
  const AgentBrandModel({
    required super.id,
    required super.brandName,
    super.domain,
    required super.brandLogo,
    super.description,
    super.isClaimed = false,
    super.isVerified = false,
    super.claimedBy,
    super.claimedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AgentBrandModel.fromJson(Map<String, dynamic> json) {
    return AgentBrandModel(
      id: json['id'] as String,
      brandName: json['brandName'] as String,
      domain: json['domain'] as String?,
      brandLogo: json['brandLogo'] as String,
      description: json['description'] as String?,
      isClaimed: json['isClaimed'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      claimedBy: json['claimedBy'] as String?,
      claimedAt: json['claimedAt'] != null 
          ? DateTime.parse(json['claimedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  factory AgentBrandModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return AgentBrandModel(
      id: documentId,
      brandName: data['brandName'] as String,
      domain: data['domain'] as String?,
      brandLogo: data['brandLogo'] as String,
      description: data['description'] as String?,
      isClaimed: data['isClaimed'] as bool? ?? false,
      isVerified: data['isVerified'] as bool? ?? false,
      claimedBy: data['claimedBy'] as String?,
      claimedAt: data['claimedAt'] != null 
          ? (data['claimedAt'] as dynamic).toDate()
          : null,
      createdAt: (data['createdAt'] as dynamic).toDate(),
      updatedAt: (data['updatedAt'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brandName': brandName,
      'domain': domain,
      'brandLogo': brandLogo,
      'description': description,
      'isClaimed': isClaimed,
      'isVerified': isVerified,
      'claimedBy': claimedBy,
      'claimedAt': claimedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'brandName': brandName,
      'domain': domain,
      'brandLogo': brandLogo,
      'description': description,
      'isClaimed': isClaimed,
      'isVerified': isVerified,
      'claimedBy': claimedBy,
      'claimedAt': claimedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory AgentBrandModel.fromEntity(AgentBrand brand) {
    return AgentBrandModel(
      id: brand.id,
      brandName: brand.brandName,
      domain: brand.domain,
      brandLogo: brand.brandLogo,
      description: brand.description,
      isClaimed: brand.isClaimed,
      isVerified: brand.isVerified,
      claimedBy: brand.claimedBy,
      claimedAt: brand.claimedAt,
      createdAt: brand.createdAt,
      updatedAt: brand.updatedAt,
    );
  }
} 