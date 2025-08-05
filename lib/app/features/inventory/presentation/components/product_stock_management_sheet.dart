import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/product.dart';
import '../../../../../shared/core/components/standard_dialog.dart';

class ProductStockManagementSheet extends StatefulWidget {
  final Product product;
  final Function(String, int) onUpdateStock;
  final Function(String) onDeleteProduct;
  final String? lookbookId;
  final Function(String, String)?
      onRemoveFromLookbook; // (lookbookId, productId)

  const ProductStockManagementSheet({
    super.key,
    required this.product,
    required this.onUpdateStock,
    required this.onDeleteProduct,
    this.lookbookId,
    this.onRemoveFromLookbook,
  });

  @override
  State<ProductStockManagementSheet> createState() =>
      _ProductStockManagementSheetState();
}

class _ProductStockManagementSheetState
    extends State<ProductStockManagementSheet> {
  late TextEditingController _stockController;
  bool _isLoading = false;
  late int _localStockQuantity;

  @override
  void initState() {
    super.initState();
    _localStockQuantity = widget.product.stockQuantity;
    _stockController = TextEditingController(
      text: _localStockQuantity.toString(),
    );
  }

  @override
  void dispose() {
    _stockController.dispose();
    super.dispose();
  }

  void _increaseStock() {
    setState(() {
      _localStockQuantity++;
      _stockController.text = _localStockQuantity.toString();
    });
  }

  void _decreaseStock() {
    if (_localStockQuantity > 0) {
      setState(() {
        _localStockQuantity--;
        _stockController.text = _localStockQuantity.toString();
      });
    }
  }

  void _updateStock(int newStock) {
    setState(() {
      _isLoading = true;
    });

    widget.onUpdateStock(widget.product.productId, newStock).then((_) {
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.pinkAccent],
              ),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text(
              'Error updating stock: $error',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  void _deleteProduct() {
    StandardDialog.showConfirmationDialog(
      context: context,
      title: 'Delete Product',
      message: 'Are you sure you want to delete "${widget.product.productName}"? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      icon: Icons.delete_forever,
      iconColor: const Color(0xFFE54D60),
      isDestructive: true,
      onConfirm: () {
        setState(() {
          _isLoading = true;
        });
        widget.onDeleteProduct(widget.product.productId).then((_) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context); // Close bottom sheet
        }).catchError((error) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.pinkAccent],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 12),
                child: Text(
                  'Error deleting product: $error',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
      },
    );
  }

  void _removeFromLookbook() {
    if (widget.lookbookId == null || widget.onRemoveFromLookbook == null)
      return;

    StandardDialog.showConfirmationDialog(
      context: context,
      title: 'Remove from Lookbook',
      message: 'Are you sure you want to remove "${widget.product.productName}" from this lookbook?',
      confirmText: 'Remove',
      cancelText: 'Cancel',
      icon: Icons.remove_circle_outline,
      iconColor: const Color(0xFFA342FF),
      onConfirm: () {
        setState(() {
          _isLoading = true;
        });
        widget.onRemoveFromLookbook!
                (widget.lookbookId!, widget.product.productId)
            .then((_) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context); // Close bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.pinkAccent],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 12),
                child: const Text(
                  'Product removed from lookbook successfully',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }).catchError((error) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.pinkAccent],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 12),
                child: Text(
                  'Error removing product: $error',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // App theme colors
    const Color textPrimaryColor = Color(0xFF000000); // Black
    const Color surfaceColor = Color(0xFFFFFFFF); // White
    const Color textSecondaryColor = Color(0xFF757575); // Gray

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Manage Stock',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textPrimaryColor,
                      ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Product Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5), // App background color
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE0E0E0), // Light border
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: widget.product.productImage != null &&
                          widget.product.productImage!.isNotEmpty
                      ? Image.network(
                          widget.product.productImage!.split(',').first,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 12),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.productName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.product.productCurrency}${widget.product.productPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Current Stock: $_localStockQuantity',
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stock Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Decrease Button
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFFE54D60), Color(0xFFA342FF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE54D60).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _isLoading ? null : _decreaseStock,
                  icon: const Icon(Icons.remove, color: Colors.white, size: 24),
                ),
              ),

              // Stock Display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  '$_localStockQuantity',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // Increase Button
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _isLoading ? null : _increaseStock,
                  icon: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Manual Stock Input
          TextField(
            controller: _stockController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Manual Stock Input',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  final newStock = int.tryParse(_stockController.text);
                  if (newStock != null && newStock >= 0) {
                    setState(() {
                      _localStockQuantity = newStock;
                    });
                  }
                },
                icon: const Icon(Icons.check),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFFA342FF), Color(0xFFE54D60)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA342FF).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () =>
                        _updateStock(_localStockQuantity),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Update Stock',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),

          // Remove from Lookbook button (if applicable)
          if (widget.lookbookId != null &&
              widget.onRemoveFromLookbook != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _removeFromLookbook,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFA342FF),
                      side: const BorderSide(color: Color(0xFFA342FF)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Remove from Lookbook'),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Delete Product Button
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFFE53E3E), Color(0xFFC53030)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE53E3E).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _deleteProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Delete Product',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
