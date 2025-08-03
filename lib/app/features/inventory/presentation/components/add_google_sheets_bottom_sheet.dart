import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
// Simple CSV parser helper
import 'package:uuid/uuid.dart';
import '../../domain/entities/product.dart';
import '../bloc/lookbook_bloc.dart';

class AddGoogleSheetsBottomSheet extends StatefulWidget {
  const AddGoogleSheetsBottomSheet({super.key});

  @override
  State<AddGoogleSheetsBottomSheet> createState() =>
      _AddGoogleSheetsBottomSheetState();
}

class _AddGoogleSheetsBottomSheetState
    extends State<AddGoogleSheetsBottomSheet> {
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
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 16),

          // Title
          const Text(
            'Upload Products from CSV',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Upload products to your personal agent collection',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Scrollable content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // CSV Format Requirements
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.purple,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'CSV Format Requirements',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Required columns: productName, productPrice, productCurrency, productSkuUniqueId, productDescription, productImage, stockQuantity',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // File selection area
                  GestureDetector(
                    onTap: _pickFile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedFile != null
                              ? Colors.purple
                              : Colors.grey[300]!,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _selectedFile != null
                                ? Icons.check_circle
                                : Icons.upload_file,
                            size: 48,
                            color: _selectedFile != null
                                ? Colors.purple
                                : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFile != null
                                ? 'File Selected: ${_selectedFile!.path.split('/').last}'
                                : 'Tap to select CSV file',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _selectedFile != null
                                  ? Colors.purple
                                  : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Maximum file size: 10MB',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_parsedProducts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.purple, Colors.pinkAccent],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_parsedProducts.length} products parsed successfully and ready for upload',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(
                      height: 80), // Extra space for the fixed button
                ],
              ),
            ),
          ),

          // Fixed Upload Button at bottom
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              top: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: (_selectedFile != null &&
                        _parsedProducts.isNotEmpty &&
                        !_isUploading)
                    ? const LinearGradient(
                        colors: [Colors.purple, Colors.pinkAccent],
                      )
                    : null,
                color: (_selectedFile == null ||
                        _parsedProducts.isEmpty ||
                        _isUploading)
                    ? Colors.grey[300]
                    : null,
                borderRadius: BorderRadius.circular(12),
                boxShadow: (_selectedFile != null &&
                        _parsedProducts.isNotEmpty &&
                        !_isUploading)
                    ? [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: ElevatedButton(
                onPressed: (_selectedFile != null &&
                        _parsedProducts.isNotEmpty &&
                        !_isUploading)
                    ? _uploadProducts
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.transparent,
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isUploading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Uploading...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _parsedProducts.isNotEmpty
                            ? 'Upload ${_parsedProducts.length} Products'
                            : 'Upload Products',
                        style: const TextStyle(
                          color: Colors.white,
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
      print('🔍 Starting CSV parsing...');
      final input = await file.readAsString();
      final List<List<String>> rows = _parseCSVString(input);

      print('📊 Found ${rows.length} rows in CSV');

      if (rows.isEmpty) {
        _showError('CSV file is empty');
        return;
      }

      // Get headers and clean them
      final originalHeaders = rows[0];
      final headers =
          originalHeaders.map((e) => e.toLowerCase().trim()).toList();

      print('📋 Headers found: $originalHeaders');
      print('📋 Cleaned headers: $headers');

      // More flexible column matching - handle common variations
      final columnMappings = <String, String>{};

      // Required columns with possible variations
      final requiredMappings = {
        'productname': [
          'productname',
          'product_name',
          'name',
          'product',
          'title',
          'product_title'
        ],
        'productprice': [
          'productprice',
          'product_price',
          'price',
          'cost',
          'amount',
          'price_available'
        ],
        'productcurrency': [
          'productcurrency',
          'product_currency',
          'currency',
          'curr'
        ],
        'productskuuniqueid': [
          'productskuuniqueid',
          'product_sku_unique_id',
          'sku',
          'product_sku',
          'sku_id',
          'product_id'
        ]
      };

      // Find matching columns
      for (final requiredField in requiredMappings.keys) {
        bool found = false;
        for (final variation in requiredMappings[requiredField]!) {
          final index = headers.indexWhere((h) => h == variation);
          if (index != -1) {
            columnMappings[requiredField] = originalHeaders[index];
            found = true;
            print('✅ Found $requiredField as "${originalHeaders[index]}"');
            break;
          }
        }
        if (!found) {
          final suggestions = requiredMappings[requiredField]!.join(', ');
          _showError(
              'Missing required column: $requiredField\nExpected one of: $suggestions\nFound columns: ${originalHeaders.join(', ')}');
          return;
        }
      }

      // Optional columns with variations
      final optionalMappings = {
        'productdescription': [
          'productdescription',
          'product_description',
          'description',
          'desc',
          'additional_description'
        ],
        'productimage': [
          'productimage',
          'product_image',
          'image',
          'imageurl',
          'image_url',
          'additional_image'
        ],
        'stockquantity': [
          'stockquantity',
          'stock_quantity',
          'quantity',
          'stock',
          'qty'
        ]
      };

      for (final optionalField in optionalMappings.keys) {
        for (final variation in optionalMappings[optionalField]!) {
          final index = headers.indexWhere((h) => h == variation);
          if (index != -1) {
            columnMappings[optionalField] = originalHeaders[index];
            print(
                '📝 Found optional $optionalField as "${originalHeaders[index]}"');
            break;
          }
        }
      }

      print('🗺️ Column mappings: $columnMappings');

      // Parse data rows
      final products = <Product>[];
      int successfulRows = 0;
      int failedRows = 0;

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];

        // Skip empty rows
        if (row.every((cell) => cell.trim().isEmpty)) {
          print('⏭️ Skipping empty row $i');
          continue;
        }

        if (row.length != originalHeaders.length) {
          print(
              '⚠️ Row $i has ${row.length} columns, expected ${originalHeaders.length}. Skipping.');
          failedRows++;
          continue;
        }

        try {
          // Create a map with original header names
          final rowData = <String, String>{};
          for (int j = 0; j < originalHeaders.length; j++) {
            rowData[originalHeaders[j]] = row[j].trim();
          }

          // Get current user ID from Firebase Auth
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser == null) {
            throw Exception('User not authenticated');
          }

          // Extract values using mapped columns
          final productName = rowData[columnMappings['productname']] ?? '';
          final priceString = rowData[columnMappings['productprice']] ?? '0';
          final currency = rowData[columnMappings['productcurrency']] ?? 'USD';
          final sku = rowData[columnMappings['productskuuniqueid']] ?? '';

          // Debug: Show actual values for first few rows
          if (i <= 3) {
            print('🔍 Row $i Debug:');
            print('  - Product Name: "$productName"');
            print('  - Price String: "$priceString"');
            print('  - Currency: "$currency"');
            print('  - SKU: "$sku"');
          }

          // Validate required fields
          if (productName.isEmpty) {
            print('⚠️ Row $i: Missing product name');
            failedRows++;
            continue;
          }
          if (sku.isEmpty) {
            print('⚠️ Row $i: Missing SKU');
            failedRows++;
            continue;
          }

          // Enhanced price parsing
          double price = 0.0;
          if (priceString.trim().isEmpty) {
            print('⚠️ Row $i: Price is empty, using default value 0.0');
            price = 0.0; // Allow empty prices, default to 0
          } else {
            // Clean price string: remove currency symbols, commas, spaces
            final cleanPriceString = priceString
                .replaceAll(
                    RegExp(r'[^\d.,]'), '') // Keep only digits, commas, dots
                .replaceAll(',', '.') // Convert commas to dots for decimal
                .trim();

            price = double.tryParse(cleanPriceString) ?? 0.0;

            if (price < 0) {
              print(
                  '⚠️ Row $i: Negative price "$priceString" -> $price, setting to 0');
              price = 0.0;
            }

            print(
                '💰 Row $i: Price "$priceString" -> cleaned "$cleanPriceString" -> $price');
          }

          // Parse optional fields
          final description = columnMappings.containsKey('productdescription')
              ? rowData[columnMappings['productdescription']]
              : null;
          final imageUrl = columnMappings.containsKey('productimage')
              ? rowData[columnMappings['productimage']]
              : null;
          final stockString = columnMappings.containsKey('stockquantity')
              ? rowData[columnMappings['stockquantity']] ?? '0'
              : '0';
          final stockQuantity = int.tryParse(stockString.trim()) ?? 0;

          final product = Product(
            productId: const Uuid().v4(),
            productName: productName,
            productDescription:
                description?.isEmpty == true ? null : description,
            productImage: imageUrl?.isEmpty == true ? null : imageUrl,
            productPrice: price,
            productCurrency: currency,
            productSkuUniqueId: sku,
            createdAt: DateTime.now(),
            stockQuantity: stockQuantity,
            createdBy: currentUser.uid,
          );

          products.add(product);
          successfulRows++;
          print('✅ Row $i: Successfully parsed product "$productName"');
        } catch (e) {
          print('❌ Error parsing row $i: $e');
          failedRows++;
          continue;
        }
      }

      print(
          '📊 Parsing complete: $successfulRows successful, $failedRows failed');

      if (products.isEmpty) {
        _showError('No valid products found in CSV file.\n'
            'Please check that your data has:\n'
            '• Product names\n'
            '• Valid prices (numbers)\n'
            '• SKU/Product IDs\n'
            '• Required columns');
        return;
      }

      setState(() {
        _parsedProducts = products;
      });

      // Show success message
      if (context.mounted) {
        final message = successfulRows == products.length
            ? 'Successfully parsed $successfulRows products!'
            : 'Parsed $successfulRows products ($failedRows rows had errors)';

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
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ CSV parsing failed: $e');
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
      // Get current user ID (agent ID)
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showError('User not authenticated');
        return;
      }
      final agentId = currentUser.uid;

      if (context.mounted) {
        // Use the new agent-specific CSV upload
        context.read<LookbookBloc>().add(UploadCsvToAgentEvent(
              agentId: agentId,
              products: _parsedProducts,
            ));

        Navigator.pop(context);

        // Show initial success message - detailed results will be shown via BLoC listener
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
              child: Row(
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Uploading ${_parsedProducts.length} products to your collection...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
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
          content: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.pinkAccent],
              ),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text(
              message,
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
