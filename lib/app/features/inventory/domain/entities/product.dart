import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String productId;
  final String productName;
  final String? productDescription;
  final String? productImage;
  final double productPrice;
  final String productCurrency;
  final String productSkuUniqueId;
  final DateTime createdAt;
  final int stockQuantity;
  final String? category;
  final List<String> lookbookIds;
  final String createdBy;

  const Product({
    required this.productId,
    required this.productName,
    this.productDescription,
    this.productImage,
    required this.productPrice,
    this.productCurrency = 'USD',
    required this.productSkuUniqueId,
    required this.createdAt,
    this.stockQuantity = 0,
    this.category,
    this.lookbookIds = const [],
    required this.createdBy,
  });

  Product copyWith({
    String? productId,
    String? productName,
    String? productDescription,
    String? productImage,
    double? productPrice,
    String? productCurrency,
    String? productSkuUniqueId,
    DateTime? createdAt,
    int? stockQuantity,
    String? category,
    List<String>? lookbookIds,
    String? createdBy,
  }) {
    return Product(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      productImage: productImage ?? this.productImage,
      productPrice: productPrice ?? this.productPrice,
      productCurrency: productCurrency ?? this.productCurrency,
      productSkuUniqueId: productSkuUniqueId ?? this.productSkuUniqueId,
      createdAt: createdAt ?? this.createdAt,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      category: category ?? this.category,
      lookbookIds: lookbookIds ?? this.lookbookIds,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        productName,
        productDescription,
        productImage,
        productPrice,
        productCurrency,
        productSkuUniqueId,
        createdAt,
        stockQuantity,
        category,
        lookbookIds,
        createdBy,
      ];
}
