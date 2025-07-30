import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import 'product_stock_management_sheet.dart';

enum ProductTileType { grid, list, compact }

class ProductTile extends StatefulWidget {
  final Product product;
  final bool specifyDimensions;
  final ProductTileType productTileType;
  final bool isProductSelected;
  final Function(String) onProductClicked;
  final Function(String, int)? onUpdateStock;
  final Function(String)? onDeleteProduct;

  const ProductTile({
    super.key,
    required this.product,
    this.specifyDimensions = false,
    this.productTileType = ProductTileType.grid,
    this.isProductSelected = false,
    required this.onProductClicked,
    this.onUpdateStock,
    this.onDeleteProduct,
  });

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {

  bool get isRecentProduct => DateTime.now()
      .subtract(const Duration(days: 1))
      .isAfter(widget.product.createdAt);

  Widget _buildProductImage() {
    if (widget.product.productImage != null &&
        widget.product.productImage!.isNotEmpty) {
      return Image.network(
        widget.product.productImage!.split(',').first,
        width: double.infinity,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            color: Colors.grey[100],
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'No image',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _showStockManagementSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductStockManagementSheet(
        product: widget.product,
        onUpdateStock: widget.onUpdateStock ?? (_, __) async {},
        onDeleteProduct: widget.onDeleteProduct ?? (_) async {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onProductClicked(widget.product.productId),
      onLongPress: _showStockManagementSheet,
      child: Container(
        height: widget.specifyDimensions ? 300.0 : 280,
        width: widget.specifyDimensions ? 200.0 : 180,
        child: Card(
          color: Colors.white,
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: widget.isProductSelected
                ? const BorderSide(color: Colors.black, width: 1)
                : BorderSide.none,
          ),
          child: Stack(
            children: [
              // Main content
              Column(
                children: [
                  // Product Image
                  Expanded(
                    flex: 4,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: _buildProductImage(),
                    ),
                  ),

                  // Product Info
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          // Product Name
                          Text(
                            widget.product.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Price with strikethrough
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      '${widget.product.productCurrency}${widget.product.productPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 16,
                                  ),
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(
                                  text:
                                      '${widget.product.productCurrency}${(widget.product.productPrice + 21.00).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFF637087),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Stock Status Badge
              Positioned(
                left: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.product.stockQuantity > 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: widget.product.stockQuantity > 0
                          ? Colors.green
                          : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.product.stockQuantity > 0
                        ? 'Stock: ${widget.product.stockQuantity}'
                        : 'Out of Stock',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.product.stockQuantity > 0
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),



              // NEW/Discount Badge
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: isRecentProduct ? Colors.black : Colors.yellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 4,
                  ),
                  child: Text(
                    isRecentProduct ? 'NEW' : '20%',
                    style: TextStyle(
                      fontSize: 12,
                      color: isRecentProduct ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
