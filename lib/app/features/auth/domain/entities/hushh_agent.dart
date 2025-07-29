import 'package:equatable/equatable.dart';

class HushhAgent extends Equatable {
  final String id;
  final String agentId;
  final String phone;
  final String? email;
  final String? name;
  final String? fullName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HushhAgent({
    required this.id,
    required this.agentId,
    required this.phone,
    this.email,
    this.name,
    this.fullName,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        agentId,
        phone,
        email,
        name,
        fullName,
        isActive,
        createdAt,
        updatedAt,
      ];
} 