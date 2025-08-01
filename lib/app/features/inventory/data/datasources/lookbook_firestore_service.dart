import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/lookbook.dart';
import '../../domain/entities/product.dart';
import '../models/lookbook_model.dart';
import '../models/product_model.dart';

class LookbookFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Collection references
  CollectionReference get _lookbooksCollection =>
      _firestore.collection('lookbooks');
  CollectionReference get _productsCollection =>
      _firestore.collection('AgentProducts');

  // Fetch lookbooks for a specific user
  Future<List<Lookbook>> getLookbooks(String hushhId) async {
    try {
      final querySnapshot = await _lookbooksCollection
          .where('hushhId', isEqualTo: hushhId)
          .where('isActive', isEqualTo: true)
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => LookbookModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch lookbooks: $e');
    }
  }

  // Create a new lookbook
  Future<Lookbook> createLookbook({
    required String name,
    String? description,
    required String hushhId,
    required List<Product> selectedProducts,
  }) async {
    try {
      final lookbookId = _uuid.v4();
      final now = DateTime.now();

      // Extract first 3 product images for cover
      final images = selectedProducts
          .where((p) => p.productImage != null && p.productImage!.isNotEmpty)
          .take(3)
          .map((p) => p.productImage!)
          .toList();

      final lookbookData = {
        'name': name,
        'description': description,
        'hushhId': hushhId,
        'numberOfProducts': selectedProducts.length,
        'images': images,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isActive': true,
      };

      // Start batch write
      final batch = _firestore.batch();

      // Create lookbook document
      final lookbookRef = _lookbooksCollection.doc(lookbookId);
      batch.set(lookbookRef, lookbookData);

      // Update products to link them to this lookbook
      for (final product in selectedProducts) {
        final productRef = _productsCollection.doc(product.productId);
        batch.update(productRef, {
          'lookbookId': lookbookId,
          'updatedAt': now.toIso8601String(),
        });
      }

      // Commit batch
      await batch.commit();

      // Return created lookbook
      return LookbookModel.fromJson({
        'id': lookbookId,
        ...lookbookData,
      }).toEntity();
    } catch (e) {
      throw Exception('Failed to create lookbook: $e');
    }
  }

  // Delete a lookbook
  Future<void> deleteLookbook(String lookbookId) async {
    try {
      final batch = _firestore.batch();

      // Mark lookbook as inactive
      final lookbookRef = _lookbooksCollection.doc(lookbookId);
      batch.update(lookbookRef, {
        'isActive': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Remove lookbook association from products
      final productsSnapshot = await _productsCollection
          .where('lookbookId', isEqualTo: lookbookId)
          .get();

      for (final doc in productsSnapshot.docs) {
        batch.update(doc.reference, {
          'lookbookId': null,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete lookbook: $e');
    }
  }

  // Fetch products
  Future<List<Product>> getProducts({
    required String hushhId,
    String? lookbookId,
  }) async {
    try {
      // Fetch from Hushhagents structure: Hushhagents/{agentId}/agentProducts/
      final querySnapshot = await _firestore
          .collection('Hushhagents')
          .doc(hushhId)
          .collection('agentProducts')
          .get();

      List<Product> products = querySnapshot.docs
          .map((doc) => ProductModel.fromJson({
                'productId': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }).toEntity())
          .toList();

      // Filter by lookbookId on client side if needed
      if (lookbookId != null) {
        products = products
            .where((product) => product.lookbookIds.contains(lookbookId))
            .toList();
      }

      // Sort by createdAt on client side
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print(
          '✅ [Products] Fetched ${products.length} products for agent: $hushhId from Hushhagents/$hushhId/agentProducts/');
      return products;
    } catch (e) {
      print('❌ [Products] Failed to fetch products for agent: $hushhId - $e');
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Add a single product
  Future<Product> addProduct(Product product) async {
    try {
      final productId =
          product.productId.isEmpty ? _uuid.v4() : product.productId;
      final now = DateTime.now();

      final productData = ProductModel(
        productId: productId,
        productName: product.productName,
        productDescription: product.productDescription,
        productImage: product.productImage,
        productPrice: product.productPrice,
        productCurrency: product.productCurrency,
        productSkuUniqueId: product.productSkuUniqueId,
        createdAt: now,
        stockQuantity: product.stockQuantity,
        category: product.category,
        lookbookIds: product.lookbookIds,
        createdBy: product.createdBy,
      ).toJson();

      // Ensure the agent document exists in Hushhagents collection
      final agentDocRef =
          _firestore.collection('Hushhagents').doc(product.createdBy);
      final agentDocSnapshot = await agentDocRef.get();

      if (!agentDocSnapshot.exists) {
        // Create the agent document with basic metadata
        await agentDocRef.set({
          'agentId': product.createdBy,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'productCount': 1,
        });
        print('📝 Created agent document: Hushhagents/${product.createdBy}');
      } else {
        // Update the existing agent document with incremented product count
        final currentData = agentDocSnapshot.data() as Map<String, dynamic>?;
        final currentProductCount = currentData?['productCount'] ?? 0;
        await agentDocRef.update({
          'updatedAt': now.toIso8601String(),
          'productCount': currentProductCount + 1,
        });
      }

      // Store in agent's subcollection: Hushhagents/{agentId}/agentProducts/{productId}
      await _firestore
          .collection('Hushhagents')
          .doc(product.createdBy)
          .collection('agentProducts')
          .doc(productId)
          .set({
        ...productData,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      // ALSO store directly in AgentProducts collection: AgentProducts/{productId}
      await _firestore.collection('AgentProducts').doc(productId).set({
        ...productData,
        'agentId': product.createdBy, // Include agentId for reference
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      print(
          '✅ [Product] Stored in: Hushhagents/${product.createdBy}/agentProducts/$productId AND AgentProducts/$productId');

      return ProductModel.fromJson({
        'productId': productId,
        ...productData,
      }).toEntity();
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  // Add multiple products (bulk upload)
  Future<void> addBulkProducts(List<Product> products) async {
    try {
      if (products.isEmpty) return;

      final batch = _firestore.batch();
      final now = DateTime.now();

      // Group products by agent to manage agent documents efficiently
      final productsByAgent = <String, List<Product>>{};
      for (final product in products) {
        productsByAgent.putIfAbsent(product.createdBy, () => []).add(product);
      }

      // For each agent, ensure their document exists and update product count
      for (final agentId in productsByAgent.keys) {
        final agentProducts = productsByAgent[agentId]!;
        final agentDocRef = _firestore.collection('Hushhagents').doc(agentId);
        final agentDocSnapshot = await agentDocRef.get();

        if (!agentDocSnapshot.exists) {
          // Create the agent document with basic metadata
          batch.set(agentDocRef, {
            'agentId': agentId,
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
            'productCount': agentProducts.length,
          });
          print('📝 Creating agent document: Hushhagents/$agentId');
        } else {
          // Update the existing agent document with new product count
          final currentData = agentDocSnapshot.data() as Map<String, dynamic>?;
          final currentProductCount = currentData?['productCount'] ?? 0;
          batch.update(agentDocRef, {
            'updatedAt': now.toIso8601String(),
            'productCount': currentProductCount + agentProducts.length,
          });
          print('📝 Updating agent document: Hushhagents/$agentId');
        }
      }

      for (final product in products) {
        final productId =
            product.productId.isEmpty ? _uuid.v4() : product.productId;

        final productData = ProductModel(
          productId: productId,
          productName: product.productName,
          productDescription: product.productDescription,
          productImage: product.productImage,
          productPrice: product.productPrice,
          productCurrency: product.productCurrency,
          productSkuUniqueId: product.productSkuUniqueId,
          createdAt: now,
          stockQuantity: product.stockQuantity,
          category: product.category,
          lookbookIds: product.lookbookIds,
          createdBy: product.createdBy,
        ).toJson();

        // Store in agent's subcollection: Hushhagents/{agentId}/agentProducts/{productId}
        final agentProductRef = _firestore
            .collection('Hushhagents')
            .doc(product.createdBy)
            .collection('agentProducts')
            .doc(productId);
        batch.set(agentProductRef, {
          ...productData,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        });
      }

      await batch.commit();
      print(
          '✅ [Bulk Products] Stored ${products.length} products in Hushhagents structure');
    } catch (e) {
      throw Exception('Failed to add bulk products: $e');
    }
  }

  /// Fetch products specifically from an agent's subcollection
  /// This method fetches products directly from Hushhagents/{agentId}/agentProducts/
  /// Use this when you want to get products belonging to a specific agent
  Future<List<Product>> getAgentProducts({
    required String agentId,
    String? lookbookId,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection('Hushhagents')
          .doc(agentId)
          .collection('agentProducts');

      // Apply limit if specified
      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      List<Product> products = querySnapshot.docs
          .map((doc) => ProductModel.fromJson({
                'productId': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }).toEntity())
          .toList();

      // Filter by lookbookId on client side if needed
      if (lookbookId != null) {
        products = products
            .where((product) => product.lookbookIds.contains(lookbookId))
            .toList();
      }

      // Sort by createdAt on client side (newest first)
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print(
          '✅ [Agent Products] Fetched ${products.length} products for agent: $agentId from Hushhagents/$agentId/agentProducts/');
      return products;
    } catch (e) {
      throw Exception('Failed to fetch agent products: $e');
    }
  }

  /// Upload CSV products specifically to an agent's collection
  /// This method is optimized for bulk CSV uploads to agent-specific collections
  Future<Map<String, dynamic>> uploadCsvProductsToAgent({
    required String agentId,
    required List<Product> products,
  }) async {
    try {
      if (products.isEmpty) {
        throw Exception('No products provided for upload');
      }

      final batch = _firestore.batch();
      final now = DateTime.now();
      final successful = <String>[];
      final failed = <Map<String, String>>[];

      // Ensure the agent document exists in Hushhagents collection
      final agentDocRef = _firestore.collection('Hushhagents').doc(agentId);
      final agentDocSnapshot = await agentDocRef.get();

      if (!agentDocSnapshot.exists) {
        // Create the agent document with basic metadata
        batch.set(agentDocRef, {
          'agentId': agentId,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'productCount': products.length,
        });
        print('📝 Creating agent document: Hushhagents/$agentId');
      } else {
        // Update the existing agent document with new product count
        final currentData = agentDocSnapshot.data() as Map<String, dynamic>?;
        final currentProductCount = currentData?['productCount'] ?? 0;
        batch.update(agentDocRef, {
          'updatedAt': now.toIso8601String(),
          'productCount': currentProductCount + products.length,
        });
        print('📝 Updating agent document: Hushhagents/$agentId');
      }

      for (final product in products) {
        try {
          final productId =
              product.productId.isEmpty ? _uuid.v4() : product.productId;

          final productData = ProductModel(
            productId: productId,
            productName: product.productName,
            productDescription: product.productDescription,
            productImage: product.productImage,
            productPrice: product.productPrice,
            productCurrency: product.productCurrency,
            productSkuUniqueId: product.productSkuUniqueId,
            createdAt: now,
            stockQuantity: product.stockQuantity,
            category: product.category,
            lookbookIds: product.lookbookIds,
            createdBy: agentId, // Ensure the agent ID is set
          ).toJson();

          // Store in agent's subcollection: Hushhagents/{agentId}/agentProducts/{productId}
          final agentProductRef = _firestore
              .collection('Hushhagents')
              .doc(agentId)
              .collection('agentProducts')
              .doc(productId);
          batch.set(agentProductRef, {
            ...productData,
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          });

          // ALSO store directly in AgentProducts collection: AgentProducts/{productId}
          final agentProductsRef =
              _firestore.collection('AgentProducts').doc(productId);
          batch.set(agentProductsRef, {
            ...productData,
            'agentId': agentId, // Include agentId for reference
            'createdAt': now.toIso8601String(),
            'updatedAt': now.toIso8601String(),
          });

          successful.add(productId);
        } catch (e) {
          failed.add({
            'productName': product.productName,
            'error': e.toString(),
          });
        }
      }

      await batch.commit();

      final result = {
        'success': true,
        'totalProducts': products.length,
        'successfulUploads': successful.length,
        'failedUploads': failed.length,
        'successful': successful,
        'failed': failed,
        'agentId': agentId,
      };

      print(
          '✅ [CSV Upload] Agent: $agentId | Success: ${successful.length} | Failed: ${failed.length}');
      print(
          '📁 Products stored in: Hushhagents/$agentId/agentProducts/ AND AgentProducts/{productId}');
      return result;
    } catch (e) {
      throw Exception('Failed to upload CSV products to agent collection: $e');
    }
  }

  // Search products
  Future<List<Product>> searchProducts({
    required String hushhId,
    required String query,
  }) async {
    try {
      // Note: Firestore doesn't support case-insensitive text search natively
      // For production, consider using Algolia or similar search service
      final querySnapshot = await _productsCollection
          .where('createdBy', isEqualTo: hushhId)
          .get();

      final allProducts = querySnapshot.docs
          .map((doc) => ProductModel.fromJson({
                'productId': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }).toEntity())
          .toList();

      // Client-side filtering for search
      return allProducts
          .where((product) =>
              product.productName.toLowerCase().contains(query.toLowerCase()) ||
              (product.productDescription
                      ?.toLowerCase()
                      .contains(query.toLowerCase()) ??
                  false) ||
              (product.category?.toLowerCase().contains(query.toLowerCase()) ??
                  false))
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      String? agentId;

      // First, try to find the product in AgentProducts collection (new dual storage)
      try {
        final agentProductDoc =
            await _firestore.collection('AgentProducts').doc(productId).get();

        if (agentProductDoc.exists) {
          final productData = agentProductDoc.data() as Map<String, dynamic>;
          agentId = productData['agentId'] as String?;

          // Delete from AgentProducts collection
          await _firestore.collection('AgentProducts').doc(productId).delete();
          print('🗑️ [Product] Deleted from: AgentProducts/$productId');
        }
      } catch (e) {
        print('⚠️ [Product] Not found in AgentProducts collection: $e');
      }

      // Also try to find in old flat structure for backward compatibility
      if (agentId == null) {
        try {
          final productDoc = await _productsCollection.doc(productId).get();
          if (productDoc.exists) {
            final productData = productDoc.data() as Map<String, dynamic>;
            agentId = productData['createdBy'] as String?;

            // Delete from old structure
            await _productsCollection.doc(productId).delete();
            print(
                '🗑️ [Product] Deleted from old structure: AgentProducts/$productId');
          }
        } catch (e) {
          print('⚠️ [Product] Not found in old structure: $e');
        }
      }

      // If we found the agent ID, also delete from Hushhagents structure
      if (agentId != null) {
        try {
          await _firestore
              .collection('Hushhagents')
              .doc(agentId)
              .collection('agentProducts')
              .doc(productId)
              .delete();

          print(
              '✅ [Product] Deleted from: Hushhagents/$agentId/agentProducts/$productId');

          // Update agent's product count
          final agentDocRef = _firestore.collection('Hushhagents').doc(agentId);
          final agentDocSnapshot = await agentDocRef.get();

          if (agentDocSnapshot.exists) {
            final currentData =
                agentDocSnapshot.data() as Map<String, dynamic>?;
            final currentProductCount = currentData?['productCount'] ?? 0;
            if (currentProductCount > 0) {
              await agentDocRef.update({
                'updatedAt': DateTime.now().toIso8601String(),
                'productCount': currentProductCount - 1,
              });
            }
          }
        } catch (e) {
          print('⚠️ [Product] Error deleting from Hushhagents structure: $e');
        }
      } else {
        throw Exception('Product not found or missing agent information');
      }

      print('✅ [Product] Successfully deleted product: $productId');
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Update a product
  Future<Product> updateProduct(Product product) async {
    try {
      final now = DateTime.now();
      final updateData = ProductModel.fromEntity(product).toJson();
      updateData['updatedAt'] = now.toIso8601String();

      // Update in Hushhagents structure
      await _firestore
          .collection('Hushhagents')
          .doc(product.createdBy)
          .collection('agentProducts')
          .doc(product.productId)
          .update(updateData);

      // ALSO update in AgentProducts collection
      await _firestore
          .collection('AgentProducts')
          .doc(product.productId)
          .update({
        ...updateData,
        'agentId': product.createdBy, // Include agentId for reference
      });

      print(
          '✅ [Product] Updated in: Hushhagents/${product.createdBy}/agentProducts/${product.productId} AND AgentProducts/${product.productId}');

      return product;
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }
}
