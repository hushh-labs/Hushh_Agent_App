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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text(
              'Are you sure you want to delete "${widget.product.productName}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.pinkAccent],
                ),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: const Text('Delete'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onProductClicked(widget.product.productId),
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

              // Stock Status and Management Section
              Positioned(
                left: 6,
                right: 6,
                bottom: 6,
                child: Row(
                  children: [
                    // Stock Status Badge (Tappable)
                    GestureDetector(
                      onTap: _showStockManagementSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
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
                            fontSize: 10,
                            color: widget.product.stockQuantity > 0
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
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
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: (!_isDecreaseInProgress &&
                                      widget.product.stockQuantity > 0)
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: (!_isDecreaseInProgress &&
                                        widget.product.stockQuantity > 0)
                                    ? Colors.orange
                                    : Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: _isDecreaseInProgress
                                ? SizedBox(
                                    width: 8,
                                    height: 8,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                      color: Colors.grey.shade400,
                                    ),
                                  )
                                : Icon(
                                    Icons.remove,
                                    size: 12,
                                    color: (!_isDecreaseInProgress &&
                                            widget.product.stockQuantity > 0)
                                        ? Colors.orange.shade700
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
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: !_isIncreaseInProgress
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: !_isIncreaseInProgress
                                    ? Colors.green
                                    : Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: _isIncreaseInProgress
                                ? SizedBox(
                                    width: 8,
                                    height: 8,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                      color: Colors.grey.shade400,
                                    ),
                                  )
                                : Icon(
                                    Icons.add,
                                    size: 12,
                                    color: !_isIncreaseInProgress
                                        ? Colors.green.shade700
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
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: !_isDeleteInProgress
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: !_isDeleteInProgress
                                    ? Colors.red
                                    : Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: _isDeleteInProgress
                                ? SizedBox(
                                    width: 8,
                                    height: 8,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                      color: Colors.grey.shade400,
                                    ),
                                  )
                                : Icon(
                                    Icons.delete_outline,
                                    size: 12,
                                    color: !_isDeleteInProgress
                                        ? Colors.red.shade700
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
