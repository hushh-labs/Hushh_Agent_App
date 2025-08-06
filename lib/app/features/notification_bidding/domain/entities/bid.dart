class Bid {
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

  Bid({
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

  @override
  String toString() {
    return 'Bid(id: $id, userId: $userId, agentId: $agentId, bidAmount: $bidAmount, expiry: $expiry, status: $status, productId: $productId, productName: $productName, productPrice: $productPrice, customerName: $customerName, createdAt: $createdAt, notificationId: $notificationId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bid &&
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