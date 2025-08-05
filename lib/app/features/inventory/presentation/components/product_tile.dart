import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import 'product_stock_management_sheet.dart';
import '../../../../../shared/core/components/standard_dialog.dart';

enum ProductTileType { grid, list, compact }

class ProductTile extends StatefulWidget {
  final Product product;
  final bool specifyDimensions;
  final ProductTileType productTileType;
  final bool isProductSelected;
  final Function(String) onProductClicked;
  final Function(String, int)? onUpdateStock;
  final Function(String)? onDeleteProduct;
  final String? lookbookId; // If provided, shows "Remove from Lookbook" option
  final Function(String, String)?
      onRemoveFromLookbook; // (lookbookId, productId)

  const ProductTile({
    super.key,
    required this.product,
    this.specifyDimensions = false,
    this.productTileType = ProductTileType.grid,
    this.isProductSelected = false,
    required this.onProductClicked,
    this.onUpdateStock,
    this.onDeleteProduct,
    this.lookbookId,
    this.onRemoveFromLookbook,
  });

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  bool _isIncreaseInProgress = false;
  bool _isDecreaseInProgress = false;
  bool _isDeleteInProgress = false;
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
        lookbookId: widget.lookbookId,
        onRemoveFromLookbook: widget.onRemoveFromLookbook,
      ),
    );
  }

  void _updateStock(int newStock) {
    final isIncrease = newStock > widget.product.stockQuantity;
    final isDecrease = newStock < widget.product.stockQuantity;

    if ((isIncrease && _isIncreaseInProgress) ||
        (isDecrease && _isDecreaseInProgress)) return;

    if (widget.onUpdateStock != null) {
      setState(() {
        if (isIncrease) {
          _isIncreaseInProgress = true;
        } else if (isDecrease) {
          _isDecreaseInProgress = true;
        }
      });

      widget.onUpdateStock!(widget.product.productId, newStock);

      // Reset after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            if (isIncrease) {
              _isIncreaseInProgress = false;
            } else if (isDecrease) {
              _isDecreaseInProgress = false;
            }
          });
        }
      });
    }
  }

  void _showDeleteConfirmation() {
    if (_isDeleteInProgress) return;

    StandardDialog.showConfirmationDialog(
      context: context,
      title: 'Delete Product',
      message: 'Are you sure you want to delete "${widget.product.productName}"?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      icon: Icons.delete_forever,
      iconColor: const Color(0xFFE54D60),
      isDestructive: true,
      onConfirm: () {
        if (widget.onDeleteProduct != null) {
          setState(() {
            _isDeleteInProgress = true;
          });

          widget.onDeleteProduct!(widget.product.productId);

          // Reset after a delay
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _isDeleteInProgress = false;
              });
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onProductClicked(widget.product.productId),
      child: Container(
        height: widget.specifyDimensions ? 300.0 : 290,
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
                    flex: 3,
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
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          // Product Name
                          Text(
                            widget.product.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
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
                                    fontSize: 14,
                                  ),
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(
                                  text:
                                      '${widget.product.productCurrency}${(widget.product.productPrice + 21.00).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFF637087),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 10,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Stock Status and Management Section
              Positioned(
                left: 4,
                right: 4,
                bottom: 4,
                child: Row(
                  children: [
                    // Stock Status Badge (Tappable)
                    Flexible(
                      child: GestureDetector(
                        onTap: _showStockManagementSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: widget.product.stockQuantity > 0
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
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
                              fontSize: 9,
                              color: widget.product.stockQuantity > 0
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Stock Management Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Decrease Stock Button
                        GestureDetector(
                          onTap: (!_isDecreaseInProgress &&
                                  widget.product.stockQuantity > 0)
                              ? () =>
                                  _updateStock(widget.product.stockQuantity - 1)
                              : null,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: (!_isDecreaseInProgress &&
                                      widget.product.stockQuantity > 0)
                                  ? const LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: [Color(0xFFE54D60), Color(0xFFA342FF)],
                                    )
                                  : null,
                              color: (!_isDecreaseInProgress &&
                                      widget.product.stockQuantity > 0)
                                  ? null
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: (!_isDecreaseInProgress &&
                                      widget.product.stockQuantity > 0)
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFE54D60).withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: _isDecreaseInProgress
                                ? const SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Icon(
                                    Icons.remove,
                                    size: 14,
                                    color: (!_isDecreaseInProgress &&
                                            widget.product.stockQuantity > 0)
                                        ? Colors.white
                                        : Colors.grey.shade400,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Increase Stock Button
                        GestureDetector(
                          onTap: !_isIncreaseInProgress
                              ? () =>
                                  _updateStock(widget.product.stockQuantity + 1)
                              : null,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: !_isIncreaseInProgress
                                  ? const LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                                    )
                                  : null,
                              color: !_isIncreaseInProgress
                                  ? null
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: !_isIncreaseInProgress
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: _isIncreaseInProgress
                                ? const SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Icon(
                                    Icons.add,
                                    size: 14,
                                    color: !_isIncreaseInProgress
                                        ? Colors.white
                                        : Colors.grey.shade400,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Delete Button
                        GestureDetector(
                          onTap: !_isDeleteInProgress
                              ? () => _showDeleteConfirmation()
                              : null,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: !_isDeleteInProgress
                                  ? const LinearGradient(
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                      colors: [Color(0xFFE53E3E), Color(0xFFC53030)],
                                    )
                                  : null,
                              color: !_isDeleteInProgress
                                  ? null
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: !_isDeleteInProgress
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFE53E3E).withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: _isDeleteInProgress
                                ? const SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Icon(
                                    Icons.delete_outline,
                                    size: 14,
                                    color: !_isDeleteInProgress
                                        ? Colors.white
                                        : Colors.grey.shade400,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
