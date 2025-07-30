import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
// Simple CSV parser helper
import 'package:uuid/uuid.dart';
import '../../domain/entities/product.dart';
import '../bloc/lookbook_bloc.dart';

class AddGoogleSheetsBottomSheet extends StatefulWidget {
  const AddGoogleSheetsBottomSheet({super.key});

  @override
  State<AddGoogleSheetsBottomSheet> createState() => _AddGoogleSheetsBottomSheetState();
}

class _AddGoogleSheetsBottomSheetState extends State<AddGoogleSheetsBottomSheet> {
  File? _selectedFile;
  bool _isUploading = false;
  List<Product> _parsedProducts = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
                const Expanded(
                  child: Text(
                    'Upload Products from CSV',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance the close button
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'CSV Format Requirements',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Required columns: productName, productPrice, productCurrency, productSkuUniqueId\n'
                          'Optional columns: productDescription, productImage, stockQuantity',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // File Selection
                  GestureDetector(
                    onTap: _pickFile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedFile != null ? Colors.green : Colors.grey[300]!,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: _selectedFile != null ? Colors.green[50] : Colors.grey[50],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _selectedFile != null ? Icons.check_circle : Icons.upload_file,
                            size: 48,
                            color: _selectedFile != null ? Colors.green : Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _selectedFile != null 
                                ? 'File Selected: ${_selectedFile!.path.split('/').last}'
                                : 'Tap to select CSV file',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _selectedFile != null ? Colors.green[700] : Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_selectedFile == null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Maximum file size: 10MB',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  if (_parsedProducts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${_parsedProducts.length} products parsed successfully',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const Spacer(),
                ],
              ),
            ),
          ),
          
          // Upload Button
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 20,
              top: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_selectedFile != null && !_isUploading) ? _uploadProducts : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Upload Products',
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
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        
        // Check file size (10MB limit)
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          _showError('File size exceeds 10MB limit');
          return;
        }

        setState(() {
          _selectedFile = file;
        });

        // Parse the CSV file
        await _parseCSV(file);
      }
    } catch (e) {
      _showError('Failed to pick file: $e');
    }
  }

  Future<void> _parseCSV(File file) async {
    try {
      final input = await file.readAsString();
      final List<List<String>> rows = _parseCSVString(input);
      
      if (rows.isEmpty) {
        _showError('CSV file is empty');
        return;
      }

      // Get headers
      final headers = rows[0].map((e) => e.toLowerCase()).toList();
      
      // Validate required columns
      final requiredColumns = ['productname', 'productprice', 'productcurrency', 'productskuuniqueid'];
      for (final required in requiredColumns) {
        if (!headers.contains(required)) {
          _showError('Missing required column: $required');
          return;
        }
      }

      // Parse data rows
      final products = <Product>[];
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length != headers.length) continue;

        try {
          final productData = <String, dynamic>{};
          for (int j = 0; j < headers.length; j++) {
            productData[headers[j]] = row[j];
          }

          final product = Product(
            productId: const Uuid().v4(),
            hushhId: 'current_user_id', // TODO: Get actual user ID
            productName: productData['productname'] ?? '',
            productDescription: productData['productdescription']?.isEmpty == true 
                ? null 
                : productData['productdescription'],
            productImage: productData['productimage']?.isEmpty == true 
                ? null 
                : productData['productimage'],
            productPrice: double.tryParse(productData['productprice']?.toString() ?? '0') ?? 0.0,
            productCurrency: productData['productcurrency'] ?? 'USD',
            productSkuUniqueId: productData['productskuuniqueid'] ?? '',
            addedAt: DateTime.now(),
            stockQuantity: int.tryParse(productData['stockquantity']?.toString() ?? '0') ?? 0,
          );

          products.add(product);
        } catch (e) {
          print('Error parsing row $i: $e');
          continue;
        }
      }

      setState(() {
        _parsedProducts = products;
      });
    } catch (e) {
      _showError('Failed to parse CSV: $e');
    }
  }

  Future<void> _uploadProducts() async {
    if (_parsedProducts.isEmpty) {
      _showError('No products to upload');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      if (context.mounted) {
        context.read<LookbookBloc>().add(AddBulkProductsEvent(_parsedProducts));
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_parsedProducts.length} products uploaded successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to upload products: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Simple CSV parser
  List<List<String>> _parseCSVString(String csvString) {
    final List<List<String>> result = [];
    final List<String> lines = csvString.split('\n');
    
    for (String line in lines) {
      if (line.trim().isEmpty) continue;
      
      final List<String> row = [];
      bool inQuotes = false;
      String currentField = '';
      
      for (int i = 0; i < line.length; i++) {
        final char = line[i];
        
        if (char == '"') {
          inQuotes = !inQuotes;
        } else if (char == ',' && !inQuotes) {
          row.add(currentField.trim());
          currentField = '';
        } else {
          currentField += char;
        }
      }
      
      // Add the last field
      row.add(currentField.trim());
      result.add(row);
    }
    
    return result;
  }
} 