import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import 'package:hushh_agent_app/core/errors/failures.dart';
import '../entities/lookbook.dart';
import '../repositories/lookbook_repository.dart';

class GetLookbooksUseCase implements UseCase<List<Lookbook>, String> {
  final LookbookRepository repository;

  GetLookbooksUseCase(this.repository);

  @override
  Future<Result<List<Lookbook>>> call(String hushhId) async {
    try {
      final lookbooks = await repository.getLookbooks(hushhId);
      return Success(lookbooks);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
} 