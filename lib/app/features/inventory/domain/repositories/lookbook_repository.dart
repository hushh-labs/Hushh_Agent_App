import '../entities/lookbook.dart';
import '../entities/product.dart';

abstract class LookbookRepository {
  Future<List<Lookbook>> getLookbooks(String hushhId);
  
  Future<Lookbook> createLookbook({
    required String name,
    String? description,
    required String hushhId,
    required List<Product> selectedProducts,
  });
  
  Future<void> deleteLookbook(String lookbookId);
  
  Future<List<Product>> getProducts({
    required String hushhId,
    String? lookbookId,
  });
  
  Future<Product> addProduct(Product product);
  
  Future<List<Product>> addBulkProducts(List<Product> products);
  
  Future<void> deleteProduct(String productId);
  
  Future<Product> updateProduct(Product product);
  
  Future<List<Product>> searchProducts({
    required String hushhId,
    required String query,
  });
} 