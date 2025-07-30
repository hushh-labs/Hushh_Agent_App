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
      // Simple query without complex filters to avoid index requirements
      final querySnapshot = await _productsCollection
          .where('createdBy', isEqualTo: hushhId)
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

      return products;
    } catch (e) {
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

      // 1. Store in main AgentProducts collection with user reference
      await _productsCollection.doc(productId).set({
        ...productData,
        'createdBy': product.createdBy, // Add user reference
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      // 2. Store in user's subcollection (Hushhagents/{userId}/agentProducts/{productId})
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

      print(
          '✅ [Product] Stored in both locations: AgentProducts/$productId and Hushhagents/${product.createdBy}/agentProducts/$productId');

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
      final batch = _firestore.batch();
      final now = DateTime.now();

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

        // 1. Store in main AgentProducts collection with user reference
        final mainProductRef = _productsCollection.doc(productId);
        batch.set(mainProductRef, {
          ...productData,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        });

        // 2. Store in user's subcollection (Hushhagents/{userId}/agentProducts/{productId})
        final userProductRef = _firestore
            .collection('Hushhagents')
            .doc(product.createdBy)
            .collection('agentProducts')
            .doc(productId);
        batch.set(userProductRef, {
          ...productData,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        });
      }

      await batch.commit();
      print(
          '✅ [Bulk Products] Stored ${products.length} products in both locations');
    } catch (e) {
      throw Exception('Failed to add bulk products: $e');
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
      // First, get the product to find the createdBy field
      final productDoc = await _productsCollection.doc(productId).get();
      if (!productDoc.exists) {
        throw Exception('Product not found');
      }

      final productData = productDoc.data() as Map<String, dynamic>;
      final createdBy = productData['createdBy'] as String;

      // Delete from both locations
      await Future.wait([
        _productsCollection.doc(productId).delete(),
        _firestore
            .collection('Hushhagents')
            .doc(createdBy)
            .collection('agentProducts')
            .doc(productId)
            .delete(),
      ]);

      print(
          '✅ [Product] Deleted from both locations: AgentProducts/$productId and Hushhagents/$createdBy/agentProducts/$productId');
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

      // Update in both locations
      await Future.wait([
        _productsCollection.doc(product.productId).update(updateData),
        _firestore
            .collection('Hushhagents')
            .doc(product.createdBy)
            .collection('agentProducts')
            .doc(product.productId)
            .update(updateData),
      ]);

      print(
          '✅ [Product] Updated in both locations: AgentProducts/${product.productId} and Hushhagents/${product.createdBy}/agentProducts/${product.productId}');

      return product;
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }
}
