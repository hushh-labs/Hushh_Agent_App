import '../entities/agent_category.dart';
import '../repositories/category_repository.dart';
import '../../../../../shared/domain/usecases/base_usecase.dart';

/// Use case for getting all categories from the remote data source
class GetCategoriesUseCase extends NoParamsUseCase<List<AgentCategory>> {
  final CategoryRepository _repository;

  GetCategoriesUseCase(this._repository);

  @override
  Future<Result<List<AgentCategory>>> call() async {
    return await _repository.getCategories();
  }
}
