import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import 'package:hushh_agent_app/core/errors/failures.dart';
import '../entities/product.dart';
import '../repositories/lookbook_repository.dart';

class GetProductsUseCase implements UseCase<List<Product>, GetProductsParams> {
  final LookbookRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<Result<List<Product>>> call(GetProductsParams params) async {
    try {
      final products = await repository.getProducts(
        hushhId: params.hushhId,
        lookbookId: params.lookbookId,
      );
      return Success(products);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
}

class GetProductsParams {
  final String hushhId;
  final String? lookbookId;

  GetProductsParams({
    required this.hushhId,
    this.lookbookId,
  });
} 