import 'package:equatable/equatable.dart';

class AgentBrand extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? logoUrl;
  final String? website;
  final String categoryId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AgentBrand({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    this.website,
    required this.categoryId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        logoUrl,
        website,
        categoryId,
        isActive,
        createdAt,
        updatedAt,
      ];
} 