import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String productId;
  final String hushhId;
  final String? lookbookId;
  final String productName;
  final String? productDescription;
  final String? productImage;
  final double productPrice;
  final String productCurrency;
  final String productSkuUniqueId;
  final DateTime addedAt;
  final int stockQuantity;
  final String? category;
  final bool isAvailable;

  const Product({
    required this.productId,
    required this.hushhId,
    this.lookbookId,
    required this.productName,
    this.productDescription,
    this.productImage,
    required this.productPrice,
    this.productCurrency = 'USD',
    required this.productSkuUniqueId,
    required this.addedAt,
    this.stockQuantity = 0,
    this.category,
    this.isAvailable = true,
  });

  Product copyWith({
    String? productId,
    String? hushhId,
    String? lookbookId,
    String? productName,
    String? productDescription,
    String? productImage,
    double? productPrice,
    String? productCurrency,
    String? productSkuUniqueId,
    DateTime? addedAt,
    int? stockQuantity,
    String? category,
    bool? isAvailable,
  }) {
    return Product(
      productId: productId ?? this.productId,
      hushhId: hushhId ?? this.hushhId,
      lookbookId: lookbookId ?? this.lookbookId,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      productImage: productImage ?? this.productImage,
      productPrice: productPrice ?? this.productPrice,
      productCurrency: productCurrency ?? this.productCurrency,
      productSkuUniqueId: productSkuUniqueId ?? this.productSkuUniqueId,
      addedAt: addedAt ?? this.addedAt,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        hushhId,
        lookbookId,
        productName,
        productDescription,
        productImage,
        productPrice,
        productCurrency,
        productSkuUniqueId,
        addedAt,
        stockQuantity,
        category,
        isAvailable,
      ];
} 