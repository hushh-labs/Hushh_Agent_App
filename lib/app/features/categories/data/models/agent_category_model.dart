import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/agent_category.dart';

/// Data model for AgentCategory that extends the domain entity
class AgentCategoryModel extends AgentCategory {
  const AgentCategoryModel({
    required super.id,
    required super.name,
    required super.description,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Factory constructor to create model from Firestore document
  factory AgentCategoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null');
    }

    return AgentCategoryModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Factory constructor to create model from Map
  factory AgentCategoryModel.fromMap(String id, Map<String, dynamic> data) {
    return AgentCategoryModel(
      id: id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert model to Map for Firestore upload
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert existing data to Map for upload (without server timestamps)
  static Map<String, dynamic> categoryDataToMap(Map<String, dynamic> data) {
    return {
      'name': data['name'],
      'description': data['description'],
      'isActive': data['isActive'] ?? true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert model to domain entity
  AgentCategory toEntity() {
    return AgentCategory(
      id: id,
      name: name,
      description: description,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() {
    return 'AgentCategoryModel(id: $id, name: $name, description: $description, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
