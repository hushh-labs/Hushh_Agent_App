import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/agent_category.dart';

class AgentCategoryModel extends AgentCategory {
  const AgentCategoryModel({
    required super.id,
    required super.name,
    required super.description,
    super.iconUrl,
    super.isActive = true,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AgentCategoryModel.fromJson(Map<String, dynamic> json) {
    return AgentCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory AgentCategoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Document data is null');
    }
    return AgentCategoryModel.fromJson({
      ...data,
      'id': snapshot.id,
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
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
} 