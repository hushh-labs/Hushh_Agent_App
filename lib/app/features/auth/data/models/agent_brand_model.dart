import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/agent_brand.dart';

class AgentBrandModel extends AgentBrand {
  const AgentBrandModel({
    required super.id,
    required super.name,
    required super.description,
    super.logoUrl,
    super.website,
    required super.categoryId,
    super.isActive = true,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AgentBrandModel.fromJson(Map<String, dynamic> json) {
    return AgentBrandModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      logoUrl: json['logoUrl'] as String?,
      website: json['website'] as String?,
      categoryId: json['categoryId'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory AgentBrandModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Document data is null');
    }
    return AgentBrandModel.fromJson({
      ...data,
      'id': snapshot.id,
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'website': website,
      'categoryId': categoryId,
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