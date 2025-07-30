import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.productId,
    required super.productName,
    super.productDescription,
    super.productImage,
    required super.productPrice,
    super.productCurrency,
    required super.productSkuUniqueId,
    required super.createdAt,
    super.stockQuantity,
    super.category,
    super.lookbookIds,
    required super.createdBy,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productDescription: json['productDescription'],
      productImage: json['productImage'],
      productPrice: (json['productPrice'] ?? 0.0).toDouble(),
      productCurrency: json['productCurrency'] ?? 'USD',
      productSkuUniqueId: json['productSkuUniqueId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      stockQuantity: json['stockQuantity'] ?? 0,
      category: json['category'],
      lookbookIds: List<String>.from(json['lookbookIds'] ?? []),
      createdBy: json['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productDescription': productDescription,
      'productImage': productImage,
      'productPrice': productPrice,
      'productCurrency': productCurrency,
      'productSkuUniqueId': productSkuUniqueId,
      'createdAt': createdAt.toIso8601String(),
      'stockQuantity': stockQuantity,
      'category': category,
      'lookbookIds': lookbookIds,
      'createdBy': createdBy,
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      productId: product.productId,
      productName: product.productName,
      productDescription: product.productDescription,
      productImage: product.productImage,
      productPrice: product.productPrice,
      productCurrency: product.productCurrency,
      productSkuUniqueId: product.productSkuUniqueId,
      createdAt: product.createdAt,
      stockQuantity: product.stockQuantity,
      category: product.category,
      lookbookIds: product.lookbookIds,
      createdBy: product.createdBy,
    );
  }

  Product toEntity() {
    return Product(
      productId: productId,
      productName: productName,
      productDescription: productDescription,
      productImage: productImage,
      productPrice: productPrice,
      productCurrency: productCurrency,
      productSkuUniqueId: productSkuUniqueId,
      createdAt: createdAt,
      stockQuantity: stockQuantity,
      category: category,
      lookbookIds: lookbookIds,
      createdBy: createdBy,
    );
  }
}
