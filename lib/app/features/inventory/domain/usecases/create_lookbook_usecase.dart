import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import 'package:hushh_agent_app/core/errors/failures.dart';
import '../entities/lookbook.dart';
import '../entities/product.dart';
import '../repositories/lookbook_repository.dart';

class CreateLookbookUseCase implements UseCase<Lookbook, CreateLookbookParams> {
  final LookbookRepository repository;

  CreateLookbookUseCase(this.repository);

  @override
  Future<Result<Lookbook>> call(CreateLookbookParams params) async {
    try {
      final lookbook = await repository.createLookbook(
        name: params.name,
        description: params.description,
        hushhId: params.hushhId,
        selectedProducts: params.selectedProducts,
      );
      return Success(lookbook);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
}

class CreateLookbookParams {
  final String name;
  final String? description;
  final String hushhId;
  final List<Product> selectedProducts;

  CreateLookbookParams({
    required this.name,
    this.description,
    required this.hushhId,
    required this.selectedProducts,
  });
} 