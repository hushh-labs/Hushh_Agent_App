import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agent_category_model.dart';

/// Abstract interface for category remote data source
abstract class CategoryRemoteDataSource {
  /// Get all categories from Firestore
  Future<List<AgentCategoryModel>> getCategories();

  /// Get category by ID from Firestore
  Future<AgentCategoryModel> getCategoryById(String id);

  /// Search categories by name
  Future<List<AgentCategoryModel>> searchCategories(String query);

  /// Upload multiple categories to Firestore
  Future<bool> uploadCategories(List<Map<String, dynamic>> categories);

  /// Add single category to Firestore
  Future<AgentCategoryModel> addCategory(Map<String, dynamic> categoryData);

  /// Update category in Firestore
  Future<AgentCategoryModel> updateCategory(
      String id, Map<String, dynamic> categoryData);

  /// Delete category from Firestore
  Future<bool> deleteCategory(String id);

  /// Check if category exists by name
  Future<bool> categoryExists(String name);
}

/// Implementation of CategoryRemoteDataSource using Firebase Firestore
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'agent_categories';

  CategoryRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _categoriesCollection =>
      _firestore.collection(_collectionName);

  @override
  Future<List<AgentCategoryModel>> getCategories() async {
    try {
      print('🔍 Fetching categories from Firestore...');

      final querySnapshot =
          await _categoriesCollection.where('isActive', isEqualTo: true).get();

      print('📊 Found ${querySnapshot.docs.length} categories');

      final categories = querySnapshot.docs
          .map((doc) => AgentCategoryModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      // Sort by name client-side
      categories.sort((a, b) => a.name.compareTo(b.name));

      print('✅ Successfully fetched and sorted categories');
      return categories;
    } catch (e) {
      print('❌ Error fetching categories: $e');
      throw Exception('Failed to fetch categories: $e');
    }
  }

  @override
  Future<AgentCategoryModel> getCategoryById(String id) async {
    try {
      print('🔍 Fetching category with ID: $id');

      final doc = await _categoriesCollection.doc(id).get();

      if (!doc.exists) {
        throw Exception('Category with ID $id not found');
      }

      final category = AgentCategoryModel.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>);
      print('✅ Successfully fetched category: ${category.name}');
      return category;
    } catch (e) {
      print('❌ Error fetching category by ID: $e');
      throw Exception('Failed to fetch category: $e');
    }
  }

  @override
  Future<List<AgentCategoryModel>> searchCategories(String query) async {
    try {
      print('🔍 Searching categories with query: "$query"');

      final querySnapshot =
          await _categoriesCollection.where('isActive', isEqualTo: true).get();

      final categories = querySnapshot.docs
          .map((doc) => AgentCategoryModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .where((category) =>
              category.name.toLowerCase().contains(query.toLowerCase()))
          .toList();

      print('📊 Found ${categories.length} matching categories');
      return categories;
    } catch (e) {
      print('❌ Error searching categories: $e');
      throw Exception('Failed to search categories: $e');
    }
  }

  @override
  Future<bool> uploadCategories(List<Map<String, dynamic>> categories) async {
    try {
      print('📤 Starting upload of ${categories.length} categories...');

      final batch = _firestore.batch();
      int count = 0;

      for (final categoryData in categories) {
        final categoryMap = AgentCategoryModel.categoryDataToMap(categoryData);
        final docRef = _categoriesCollection.doc();
        batch.set(docRef, categoryMap);
        count++;

        print(
            '📝 Prepared category ${count}/${categories.length}: ${categoryData['name']}');
      }

      await batch.commit();
      print('🎉 Successfully uploaded all ${categories.length} categories!');
      return true;
    } catch (e) {
      print('❌ Error uploading categories: $e');
      throw Exception('Failed to upload categories: $e');
    }
  }

  @override
  Future<AgentCategoryModel> addCategory(
      Map<String, dynamic> categoryData) async {
    try {
      print('📤 Adding new category: ${categoryData['name']}');

      final categoryMap = AgentCategoryModel.categoryDataToMap(categoryData);
      final docRef = await _categoriesCollection.add(categoryMap);

      final doc = await docRef.get();
      final category = AgentCategoryModel.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>);

      print('✅ Successfully added category: ${category.name}');
      return category;
    } catch (e) {
      print('❌ Error adding category: $e');
      throw Exception('Failed to add category: $e');
    }
  }

  @override
  Future<AgentCategoryModel> updateCategory(
      String id, Map<String, dynamic> categoryData) async {
    try {
      print('📝 Updating category with ID: $id');

      final updateData = {
        ...categoryData,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _categoriesCollection.doc(id).update(updateData);

      final doc = await _categoriesCollection.doc(id).get();
      final category = AgentCategoryModel.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>);

      print('✅ Successfully updated category: ${category.name}');
      return category;
    } catch (e) {
      print('❌ Error updating category: $e');
      throw Exception('Failed to update category: $e');
    }
  }

  @override
  Future<bool> deleteCategory(String id) async {
    try {
      print('🗑️ Deleting category with ID: $id');

      await _categoriesCollection.doc(id).delete();

      print('✅ Successfully deleted category');
      return true;
    } catch (e) {
      print('❌ Error deleting category: $e');
      throw Exception('Failed to delete category: $e');
    }
  }

  @override
  Future<bool> categoryExists(String name) async {
    try {
      print('🔍 Checking if category exists: "$name"');

      final querySnapshot = await _categoriesCollection
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      final exists = querySnapshot.docs.isNotEmpty;
      print('📊 Category "$name" exists: $exists');
      return exists;
    } catch (e) {
      print('❌ Error checking category existence: $e');
      throw Exception('Failed to check category existence: $e');
    }
  }
}
