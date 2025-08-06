import 'package:cloud_firestore/cloud_firestore.dart';

class BidModel {
  final String? id;
  final String userId;
  final String agentId;
  final double bidAmount;
  final DateTime expiry;
  final String status;
  final String productId;
  final String productName;
  final String productPrice;
  final String customerName;
  final DateTime createdAt;
  final String notificationId;

  BidModel({
    this.id,
    required this.userId,
    required this.agentId,
    required this.bidAmount,
    required this.expiry,
    required this.status,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.customerName,
    required this.createdAt,
    required this.notificationId,
  });

  factory BidModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BidModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      agentId: data['agentId'] ?? '',
      bidAmount: (data['bidAmount'] ?? 0).toDouble(),
      expiry: (data['expiry'] as Timestamp).toDate(),
      status: data['status'] ?? 'sent',
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productPrice: data['productPrice'] ?? '',
      customerName: data['customerName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      notificationId: data['notificationId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'agentId': agentId,
      'bidAmount': bidAmount,
      'expiry': Timestamp.fromDate(expiry),
      'status': status,
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'customerName': customerName,
      'createdAt': Timestamp.fromDate(createdAt),
      'notificationId': notificationId,
    };
  }

  BidModel copyWith({
    String? id,
    String? userId,
    String? agentId,
    double? bidAmount,
    DateTime? expiry,
    String? status,
    String? productId,
    String? productName,
    String? productPrice,
    String? customerName,
    DateTime? createdAt,
    String? notificationId,
  }) {
    return BidModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      agentId: agentId ?? this.agentId,
      bidAmount: bidAmount ?? this.bidAmount,
      expiry: expiry ?? this.expiry,
      status: status ?? this.status,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      customerName: customerName ?? this.customerName,
      createdAt: createdAt ?? this.createdAt,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  @override
  String toString() {
    return 'BidModel(id: $id, userId: $userId, agentId: $agentId, bidAmount: $bidAmount, expiry: $expiry, status: $status, productId: $productId, productName: $productName, productPrice: $productPrice, customerName: $customerName, createdAt: $createdAt, notificationId: $notificationId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BidModel &&
        other.id == id &&
        other.userId == userId &&
        other.agentId == agentId &&
        other.bidAmount == bidAmount &&
        other.expiry == expiry &&
        other.status == status &&
        other.productId == productId &&
        other.productName == productName &&
        other.productPrice == productPrice &&
        other.customerName == customerName &&
        other.createdAt == createdAt &&
        other.notificationId == notificationId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        agentId.hashCode ^
        bidAmount.hashCode ^
        expiry.hashCode ^
        status.hashCode ^
        productId.hashCode ^
        productName.hashCode ^
        productPrice.hashCode ^
        customerName.hashCode ^
        createdAt.hashCode ^
        notificationId.hashCode;
  }
} 