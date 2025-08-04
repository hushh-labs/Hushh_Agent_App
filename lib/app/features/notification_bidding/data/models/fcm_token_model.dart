import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/fcm_token.dart';

class FcmTokenModel extends FcmToken {
  const FcmTokenModel({
    required super.id,
    required super.userId,
    required super.token,
    required super.platform,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FcmTokenModel.fromJson(Map<String, dynamic> json) {
    return FcmTokenModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      token: json['fcm_token'] as String, // Using fcm_token as field name
      platform: json['platform'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory FcmTokenModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('Document data is null');
    }
    return FcmTokenModel.fromJson({
      ...data,
      'id': snapshot.id,
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fcm_token': token, // Using fcm_token as field name
      'platform': platform,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Remove id since it's the document ID
    return json;
  }

  factory FcmTokenModel.create({
    required String userId,
    required String token,
    required String platform,
  }) {
    final now = DateTime.now();

    return FcmTokenModel(
      id: '', // Will be set by Firestore
      userId: userId,
      token: token,
      platform: platform,
      createdAt: now,
      updatedAt: now,
    );
  }

  FcmTokenModel copyWith({
    String? id,
    String? userId,
    String? token,
    String? platform,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FcmTokenModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      platform: platform ?? this.platform,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
