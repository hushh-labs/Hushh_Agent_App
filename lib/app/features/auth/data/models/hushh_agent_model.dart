import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/hushh_agent.dart';

class HushhAgentModel extends HushhAgent {
  const HushhAgentModel({
    required super.id,
    required super.agentId,
    required super.phone,
    super.email,
    super.name,
    super.fullName,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory HushhAgentModel.fromJson(Map<String, dynamic> json) {
    return HushhAgentModel(
      id: json['id'] as String,
      agentId: json['agentId'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      name: json['name'] as String?,
      fullName: json['fullName'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory HushhAgentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Document data is null');
    }
    return HushhAgentModel.fromJson({
      ...data,
      'id': snapshot.id,
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentId': agentId,
      'phone': phone,
      'email': email,
      'name': name,
      'fullName': fullName,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Remove id since it's the document ID
    return json;
  }

  factory HushhAgentModel.create({
    String phone = '',
    String? email,
    String? name,
    String? fullName,
  }) {
    final now = DateTime.now();
    final agentId = 'AGENT_${DateTime.now().millisecondsSinceEpoch}';
    
    return HushhAgentModel(
      id: '', // Will be set by Firestore
      agentId: agentId,
      phone: phone,
      email: email,
      name: name,
      fullName: fullName,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  HushhAgentModel copyWith({
    String? id,
    String? agentId,
    String? phone,
    String? email,
    String? name,
    String? fullName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HushhAgentModel(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 