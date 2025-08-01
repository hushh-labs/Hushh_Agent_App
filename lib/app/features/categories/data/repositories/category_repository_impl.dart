import '../../domain/entities/agent_category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';
import '../../../../../shared/domain/usecases/base_usecase.dart';
import '../../../../../core/errors/failures.dart';

/// Implementation of CategoryRepository
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  CategoryRepositoryImpl({
    required CategoryRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Result<List<AgentCategory>>> getCategories() async {
    try {
      final categoryModels = await _remoteDataSource.getCategories();
      final categories =
          categoryModels.map((model) => model.toEntity()).toList();
      return Success(categories);
    } on Exception catch (e) {
      return Failed(GeneralFailure(e.toString()));
    } catch (e) {
      return Failed(GeneralFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<AgentCategory>> getCategoryById(String id) async {
    try {
      final categoryModel = await _remoteDataSource.getCategoryById(id);
      return Success(categoryModel.toEntity());
    } on Exception catch (e) {
      if (e.toString().contains('not found')) {
        return Failed(NotFoundFailure('Category with ID $id not found'));
      }
      return Failed(GeneralFailure(e.toString()));
    } catch (e) {
      return Failed(GeneralFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<AgentCategory>>> searchCategories(String query) async {
    try {
      final categoryModels = await _remoteDataSource.searchCategories(query);
      final categories =
          categoryModels.map((model) => model.toEntity()).toList();
      return Success(categories);
    } on Exception catch (e) {
      return Failed(GeneralFailure(e.toString()));
    } catch (e) {
      return Failed(GeneralFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<bool>> uploadCategories(
      List<Map<String, dynamic>> categories) async {
    try {
      final result = await _remoteDataSource.uploadCategories(categories);
      return Success(result);
    } on Exception catch (e) {
      return Failed(GeneralFailure(e.toString()));
    } catch (e) {
      return Failed(GeneralFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<AgentCategory>> addCategory(
      Map<String, dynamic> categoryData) async {
    try {
      final categoryModel = await _remoteDataSource.addCategory(categoryData);
      return Success(categoryModel.toEntity());
    } on Exception catch (e) {
      return Failed(GeneralFailure(e.toString()));
    } catch (e) {
      return Failed(GeneralFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<AgentCategory>> updateCategory(
      String id, Map<String, dynamic> categoryData) async {
    try {
      final categoryModel =
          await _remoteDataSource.updateCategory(id, categoryData);
      return Success(categoryModel.toEntity());
    } on Exception catch (e) {
      if (e.toString().contains('not found')) {
        return Failed(NotFoundFailure('Category with ID $id not found'));
      }
      return Failed(GeneralFailure(e.toString()));
    } catch (e) {
      return Failed(GeneralFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<bool>> deleteCategory(String id) async {
    try {
      final result = await _remoteDataSource.deleteCategory(id);
      return Success(result);
    } on Exception catch (e) {
      if (e.toString().contains('not found')) {
        return Failed(NotFoundFailure('Category with ID $id not found'));
      }
      return Failed(GeneralFailure(e.toString()));
    } catch (e) {
      return Failed(GeneralFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<bool>> categoryExists(String name) async {
    try {
      final result = await _remoteDataSource.categoryExists(name);
      return Success(result);
    } on Exception catch (e) {
      return Failed(GeneralFailure(e.toString()));
    } catch (e) {
      return Failed(GeneralFailure('Unexpected error: $e'));
    }
  }
}
