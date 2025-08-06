import 'package:equatable/equatable.dart';

class Lookbook extends Equatable {
  final String id;
  final String lookbookName;
  final List<String> products; // Array of product IDs
  final DateTime createdAt;
  final String agentId; // Changed from hushhId to agentId
  final String? description; // Optional description

  const Lookbook({
    required this.id,
    required this.lookbookName,
    required this.products,
    required this.createdAt,
    required this.agentId,
    this.description,
  });

  Lookbook copyWith({
    String? id,
    String? lookbookName,
    List<String>? products,
    DateTime? createdAt,
    String? agentId,
    String? description,
  }) {
    return Lookbook(
      id: id ?? this.id,
      lookbookName: lookbookName ?? this.lookbookName,
      products: products ?? this.products,
      createdAt: createdAt ?? this.createdAt,
      agentId: agentId ?? this.agentId,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
        id,
        lookbookName,
        products,
        createdAt,
        agentId,
        description,
      ];
}
