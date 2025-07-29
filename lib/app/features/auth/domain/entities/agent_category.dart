import 'package:equatable/equatable.dart';

class AgentCategory extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AgentCategory({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
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
        isActive,
        createdAt,
        updatedAt,
      ];
} 