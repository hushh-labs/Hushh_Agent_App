import '../../domain/entities/lookbook.dart';

class LookbookModel extends Lookbook {
  const LookbookModel({
    required super.id,
    required super.name,
    super.description,
    required super.hushhId,
    required super.numberOfProducts,
    required super.images,
    required super.createdAt,
    required super.updatedAt,
    super.isActive,
  });

  factory LookbookModel.fromJson(Map<String, dynamic> json) {
    return LookbookModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      hushhId: json['hushhId'] ?? '',
      numberOfProducts: json['numberOfProducts'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'hushhId': hushhId,
      'numberOfProducts': numberOfProducts,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory LookbookModel.fromEntity(Lookbook lookbook) {
    return LookbookModel(
      id: lookbook.id,
      name: lookbook.name,
      description: lookbook.description,
      hushhId: lookbook.hushhId,
      numberOfProducts: lookbook.numberOfProducts,
      images: lookbook.images,
      createdAt: lookbook.createdAt,
      updatedAt: lookbook.updatedAt,
      isActive: lookbook.isActive,
    );
  }

  Lookbook toEntity() {
    return Lookbook(
      id: id,
      name: name,
      description: description,
      hushhId: hushhId,
      numberOfProducts: numberOfProducts,
      images: images,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }
} 