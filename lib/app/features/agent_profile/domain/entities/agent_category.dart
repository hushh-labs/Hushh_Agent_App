import 'package:equatable/equatable.dart';

class AgentCategory extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final List<String>? subcategories;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AgentCategory({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    this.subcategories,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, 
    name, 
    description, 
    iconUrl, 
    subcategories, 
    isActive, 
    createdAt, 
    updatedAt
  ];

  AgentCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    List<String>? subcategories,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AgentCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      subcategories: subcategories ?? this.subcategories,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 