import 'package:equatable/equatable.dart';

class Lookbook extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String hushhId;
  final int numberOfProducts;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const Lookbook({
    required this.id,
    required this.name,
    this.description,
    required this.hushhId,
    required this.numberOfProducts,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  Lookbook copyWith({
    String? id,
    String? name,
    String? description,
    String? hushhId,
    int? numberOfProducts,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Lookbook(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      hushhId: hushhId ?? this.hushhId,
      numberOfProducts: numberOfProducts ?? this.numberOfProducts,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        hushhId,
        numberOfProducts,
        images,
        createdAt,
        updatedAt,
        isActive,
      ];
} 