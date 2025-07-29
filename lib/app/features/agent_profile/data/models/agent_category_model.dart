import '../../domain/entities/agent_category.dart';

class AgentCategoryModel extends AgentCategory {
  const AgentCategoryModel({
    required super.id,
    required super.name,
    super.description,
    super.iconUrl,
    super.subcategories,
    super.isActive = true,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AgentCategoryModel.fromJson(Map<String, dynamic> json) {
    return AgentCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String?,
      subcategories: json['subcategories'] != null 
          ? List<String>.from(json['subcategories'] as List)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  factory AgentCategoryModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return AgentCategoryModel(
      id: documentId,
      name: data['name'] as String,
      description: data['description'] as String?,
      iconUrl: data['iconUrl'] as String?,
      subcategories: data['subcategories'] != null 
          ? List<String>.from(data['subcategories'] as List)
          : null,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as dynamic).toDate(),
      updatedAt: (data['updatedAt'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'subcategories': subcategories,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'subcategories': subcategories,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory AgentCategoryModel.fromEntity(AgentCategory category) {
    return AgentCategoryModel(
      id: category.id,
      name: category.name,
      description: category.description,
      iconUrl: category.iconUrl,
      subcategories: category.subcategories,
      isActive: category.isActive,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }
} 