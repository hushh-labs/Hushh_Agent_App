import 'package:equatable/equatable.dart';

class AgentBrand extends Equatable {
  final String id;
  final String brandName;
  final String? domain;
  final String brandLogo;
  final String? description;
  final bool isClaimed;
  final bool isVerified;
  final String? claimedBy;
  final DateTime? claimedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AgentBrand({
    required this.id,
    required this.brandName,
    this.domain,
    required this.brandLogo,
    this.description,
    this.isClaimed = false,
    this.isVerified = false,
    this.claimedBy,
    this.claimedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    brandName,
    domain,
    brandLogo,
    description,
    isClaimed,
    isVerified,
    claimedBy,
    claimedAt,
    createdAt,
    updatedAt,
  ];

  AgentBrand copyWith({
    String? id,
    String? brandName,
    String? domain,
    String? brandLogo,
    String? description,
    bool? isClaimed,
    bool? isVerified,
    String? claimedBy,
    DateTime? claimedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AgentBrand(
      id: id ?? this.id,
      brandName: brandName ?? this.brandName,
      domain: domain ?? this.domain,
      brandLogo: brandLogo ?? this.brandLogo,
      description: description ?? this.description,
      isClaimed: isClaimed ?? this.isClaimed,
      isVerified: isVerified ?? this.isVerified,
      claimedBy: claimedBy ?? this.claimedBy,
      claimedAt: claimedAt ?? this.claimedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 