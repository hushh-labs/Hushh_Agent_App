import '../../domain/entities/lookbook.dart';

class LookbookModel extends Lookbook {
  const LookbookModel({
    required super.id,
    required super.lookbookName,
    required super.products,
    required super.createdAt,
    required super.agentId,
    super.description,
  });

  factory LookbookModel.fromJson(Map<String, dynamic> json) {
    return LookbookModel(
      id: json['id'] ?? '',
      lookbookName: json['lookbookName'] ?? '',
      products: List<String>.from(json['products'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      agentId: json['agentId'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lookbookName': lookbookName,
      'products': products,
      'createdAt': createdAt.toIso8601String(),
      'agentId': agentId,
      'description': description,
    };
  }

  factory LookbookModel.fromEntity(Lookbook lookbook) {
    return LookbookModel(
      id: lookbook.id,
      lookbookName: lookbook.lookbookName,
      products: lookbook.products,
      createdAt: lookbook.createdAt,
      agentId: lookbook.agentId,
      description: lookbook.description,
    );
  }

  Lookbook toEntity() {
    return Lookbook(
      id: id,
      lookbookName: lookbookName,
      products: products,
      createdAt: createdAt,
      agentId: agentId,
      description: description,
    );
  }
}
