import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/product.dart';

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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${widget.product.productName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
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
            style: TextButton.styleFrom(foregroundColor: Colors.purple),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _removeFromLookbook() {
    if (widget.lookbookId == null || widget.onRemoveFromLookbook == null)
      return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Lookbook'),
        content: Text(
          'Are you sure you want to remove "${widget.product.productName}" from this lookbook?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
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
            style: TextButton.styleFrom(foregroundColor: Colors.purple),
            child: const Text('Remove'),
          ),
        ],
      ),
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
                        style: const TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Current Stock: $_localStockQuantity',
                        style: TextStyle(
                          color: textSecondaryColor,
                          fontSize: 14,
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
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _decreaseStock,
                  icon: const Icon(Icons.remove),
                  label: const Text('Decrease'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _increaseStock,
                  icon: const Icon(Icons.add),
                  label: const Text('Increase'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[100],
                    foregroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Manual Stock Input
          Text(
            'Set Stock Quantity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: textPrimaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Only allow digits
                  ],
                  onChanged: (value) {
                    final newStock = int.tryParse(value);
                    if (newStock != null && newStock >= 0) {
                      setState(() {
                        _localStockQuantity = newStock;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter stock quantity',
                    hintStyle: TextStyle(color: textSecondaryColor),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: textSecondaryColor),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: textSecondaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Save Changes Button
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.pinkAccent],
              ),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: ElevatedButton.icon(
              onPressed:
                  _isLoading ? null : () => _updateStock(_localStockQuantity),
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Remove from Lookbook Button (only shown in lookbook context)
          if (widget.lookbookId != null &&
              widget.onRemoveFromLookbook != null) ...[
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.pinkAccent],
                ),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _removeFromLookbook,
                icon: const Icon(Icons.remove_circle_outline),
                label: const Text('Remove from Lookbook'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Delete Button
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.pinkAccent],
              ),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _deleteProduct,
              icon: const Icon(Icons.delete),
              label: const Text('Delete Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(child: CircularProgressIndicator()),
            ),

          // Bottom padding for safe area
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
