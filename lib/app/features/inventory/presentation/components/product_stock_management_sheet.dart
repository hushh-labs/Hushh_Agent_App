import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';

class ProductStockManagementSheet extends StatefulWidget {
  final Product product;
  final Function(String, int) onUpdateStock;
  final Function(String) onDeleteProduct;

  const ProductStockManagementSheet({
    super.key,
    required this.product,
    required this.onUpdateStock,
    required this.onDeleteProduct,
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
        SnackBar(content: Text('Error updating stock: $error')),
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
                  SnackBar(content: Text('Error deleting product: $error')),
                );
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
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
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.product.productCurrency}${widget.product.productPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Current Stock: $_localStockQuantity',
                        style: TextStyle(
                          color: Colors.grey[600],
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
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final newStock = int.tryParse(value);
                    if (newStock != null && newStock >= 0) {
                      setState(() {
                        _localStockQuantity = newStock;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter stock quantity',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  _isLoading ? null : () => _updateStock(_localStockQuantity),
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Delete Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _deleteProduct,
              icon: const Icon(Icons.delete),
              label: const Text('Delete Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
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
