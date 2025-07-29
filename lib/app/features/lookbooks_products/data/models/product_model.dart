import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.productId,
    required super.hushhId,
    super.lookbookId,
    required super.productName,
    super.productDescription,
    super.productImage,
    required super.productPrice,
    super.productCurrency,
    required super.productSkuUniqueId,
    required super.addedAt,
    super.stockQuantity,
    super.category,
    super.isAvailable,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['productId'] ?? '',
      hushhId: json['hushhId'] ?? '',
      lookbookId: json['lookbookId'],
      productName: json['productName'] ?? '',
      productDescription: json['productDescription'],
      productImage: json['productImage'],
      productPrice: (json['productPrice'] ?? 0.0).toDouble(),
      productCurrency: json['productCurrency'] ?? 'USD',
      productSkuUniqueId: json['productSkuUniqueId'] ?? '',
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'])
          : DateTime.now(),
      stockQuantity: json['stockQuantity'] ?? 0,
      category: json['category'],
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'hushhId': hushhId,
      'lookbookId': lookbookId,
      'productName': productName,
      'productDescription': productDescription,
      'productImage': productImage,
      'productPrice': productPrice,
      'productCurrency': productCurrency,
      'productSkuUniqueId': productSkuUniqueId,
      'addedAt': addedAt.toIso8601String(),
      'stockQuantity': stockQuantity,
      'category': category,
      'isAvailable': isAvailable,
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      productId: product.productId,
      hushhId: product.hushhId,
      lookbookId: product.lookbookId,
      productName: product.productName,
      productDescription: product.productDescription,
      productImage: product.productImage,
      productPrice: product.productPrice,
      productCurrency: product.productCurrency,
      productSkuUniqueId: product.productSkuUniqueId,
      addedAt: product.addedAt,
      stockQuantity: product.stockQuantity,
      category: product.category,
      isAvailable: product.isAvailable,
    );
  }

  Product toEntity() {
    return Product(
      productId: productId,
      hushhId: hushhId,
      lookbookId: lookbookId,
      productName: productName,
      productDescription: productDescription,
      productImage: productImage,
      productPrice: productPrice,
      productCurrency: productCurrency,
      productSkuUniqueId: productSkuUniqueId,
      addedAt: addedAt,
      stockQuantity: stockQuantity,
      category: category,
      isAvailable: isAvailable,
    );
  }
} 