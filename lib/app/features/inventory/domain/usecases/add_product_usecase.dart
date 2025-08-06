import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import 'package:hushh_agent_app/core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/lookbook_repository.dart';

class AddProductUseCase implements UseCase<Product, AddProductParams> {
  final LookbookRepository repository;

  AddProductUseCase(this.repository);

  @override
  Future<Result<Product>> call(AddProductParams params) async {
    try {
      final product = await repository.addProduct(params.product);
      return Success(product);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
}

class AddProductParams {
  final Product product;

  AddProductParams({required this.product});
}

class AddBulkProductsUseCase implements UseCase<List<Product>, AddBulkProductsParams> {
  final LookbookRepository repository;

  AddBulkProductsUseCase(this.repository);

  @override
  Future<Result<List<Product>>> call(AddBulkProductsParams params) async {
    try {
      final products = await repository.addBulkProducts(params.products);
      return Success(products);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
}

class AddBulkProductsParams {
  final List<Product> products;

  AddBulkProductsParams({required this.products});
} 