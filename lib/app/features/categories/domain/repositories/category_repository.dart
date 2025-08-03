import '../entities/agent_category.dart';
import '../../../../../shared/domain/usecases/base_usecase.dart';
import '../../../../../core/errors/failures.dart';

/// Abstract repository interface for category operations
abstract class CategoryRepository {
  /// Get all categories from remote data source
  Future<Result<List<AgentCategory>>> getCategories();

  /// Get category by ID
  Future<Result<AgentCategory>> getCategoryById(String id);

  /// Search categories by name
  Future<Result<List<AgentCategory>>> searchCategories(String query);

  /// Upload multiple categories to remote data source
  Future<Result<bool>> uploadCategories(List<Map<String, dynamic>> categories);

  /// Add single category
  Future<Result<AgentCategory>> addCategory(Map<String, dynamic> categoryData);

  /// Update category
  Future<Result<AgentCategory>> updateCategory(
      String id, Map<String, dynamic> categoryData);

  /// Delete category
  Future<Result<bool>> deleteCategory(String id);

  /// Check if category exists by name
  Future<Result<bool>> categoryExists(String name);
}
