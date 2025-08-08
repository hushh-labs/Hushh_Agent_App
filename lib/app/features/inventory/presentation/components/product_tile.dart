import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
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
  Timer? _repeatTimer;
  int _repeatBaseStock = 0;
  int _repeatCurrentStock = 0;
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

  void _startRepeatIncrease() {
    if (widget.onUpdateStock == null) return;
    _repeatBaseStock = widget.product.stockQuantity;
    _repeatCurrentStock = _repeatBaseStock;
    _repeatTimer?.cancel();
    _repeatTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      _repeatCurrentStock += 1;
      widget.onUpdateStock!(widget.product.productId, _repeatCurrentStock);
    });
  }

  void _startRepeatDecrease() {
    if (widget.onUpdateStock == null) return;
    _repeatBaseStock = widget.product.stockQuantity;
    _repeatCurrentStock = _repeatBaseStock;
    _repeatTimer?.cancel();
    _repeatTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (_repeatCurrentStock > 0) {
        _repeatCurrentStock -= 1;
        widget.onUpdateStock!(widget.product.productId, _repeatCurrentStock);
      }
    });
  }

  void _stopRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  void _changeStockBy(int delta) {
    final int current = widget.product.stockQuantity;
    int next = current + delta;
    if (next < 0) next = 0;
    _updateStock(next);
  }

  void _showQuickActionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final controller = TextEditingController(text: '1');
        return StatefulBuilder(
          builder: (context, setStateSB) {
            bool isAdd = true;
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.product.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Amount input with +/- circles in the same row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              labelText: 'Amount',
                              hintText: 'Enter quantity',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            onChanged: (_) => setStateSB(() {}),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Minus circle (off-black)
                        InkWell(
                          onTap: () {
                            isAdd = false;
                            final current = int.tryParse(controller.text) ?? 0;
                            final next = (current - 1).clamp(0, 999999);
                            controller.text = next.toString();
                            setStateSB(() {});
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.remove, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Plus circle (off-black)
                        InkWell(
                          onTap: () {
                            isAdd = true;
                            final current = int.tryParse(controller.text) ?? 0;
                            final next = (current + 1).clamp(0, 999999);
                            controller.text = next.toString();
                            setStateSB(() {});
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Submit and Delete buttons below
                    Row(
                      children: [
                        Expanded(
                          child: _gradientActionButton(
                            label: 'Submit',
                            onTap: () {
                              final amt = int.tryParse(controller.text) ?? 0;
                              if (amt > 0) {
                                Navigator.pop(context);
                                _changeStockBy(isAdd ? amt : -amt);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _gradientIconButton(
                            icon: Icons.delete_outline,
                            onTap: () {
                              Navigator.pop(context);
                              _showDeleteConfirmation();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _gradientActionButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _gradientIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
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
      onLongPress: _showQuickActionsSheet,
      child: Container(
        height: widget.specifyDimensions ? 220.0 : 200,
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
                  // Product Image (slightly larger height)
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
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
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
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Removed inline quick-actions; now provided via long-press sheet

              // Bottom controls: quantity pill (− count +) with adaptive layout
              Positioned(
                left: 8,
                right: 8,
                bottom: 4,
                child: Row(
                  children: [
                    // Stock label (gradient) - expands and scales if tight
                    Expanded(
                      child: GestureDetector(
                        onTap: _showStockManagementSheet,
                        child: Builder(builder: (context) {
                          final gradient = const LinearGradient(colors: [Color(0xFFE54D60), Color(0xFFA342FF)]);
                          final shader = gradient.createShader(const Rect.fromLTWH(0, 0, 200, 20));
                          return FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Stock: ${widget.product.stockQuantity}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                foreground: Paint()..shader = shader,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Quantity controls - flex and scale within remaining width
                    Flexible(
                      child: FittedBox(
                        alignment: Alignment.centerRight,
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // minus (off-black, larger)
                                  GestureDetector(
                                    onTap: (!_isDecreaseInProgress && widget.product.stockQuantity > 0)
                                        ? () => _updateStock(widget.product.stockQuantity - 1)
                                        : null,
                                    onLongPressStart: (_) => _startRepeatDecrease(),
                                    onLongPressEnd: (_) => _stopRepeat(),
                                    child: const Icon(
                                      Icons.remove_circle,
                                      size: 26,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // plus (off-black, larger)
                                  GestureDetector(
                                    onTap: !_isIncreaseInProgress
                                        ? () => _updateStock(widget.product.stockQuantity + 1)
                                        : null,
                                    onLongPressStart: (_) => _startRepeatIncrease(),
                                    onLongPressEnd: (_) => _stopRepeat(),
                                    child: const Icon(
                                      Icons.add_circle,
                                      size: 26,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

  @override
  void dispose() {
    _repeatTimer?.cancel();
    super.dispose();
  }
}
