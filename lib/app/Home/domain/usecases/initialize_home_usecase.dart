import '../../../../shared/domain/usecases/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/home_repository.dart';

/// Parameters for initializing home
class InitializeHomeParams extends UseCaseParams {
  final String? preferredSection;

  const InitializeHomeParams({this.preferredSection});

  @override
  List<Object?> get props => [preferredSection];
}

/// Use case for initializing home
class InitializeHomeUseCase implements UseCase<void, InitializeHomeParams> {
  final HomeRepository _homeRepository;

  InitializeHomeUseCase(this._homeRepository);

  @override
  Future<Result<void>> call(InitializeHomeParams params) async {
    try {
      await _homeRepository.initializeHome();
      
      if (params.preferredSection != null) {
        await _homeRepository.updateActiveSection(params.preferredSection!);
      }
      
      return const Success(null);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
} 