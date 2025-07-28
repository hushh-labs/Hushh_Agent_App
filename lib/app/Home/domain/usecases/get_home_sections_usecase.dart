import '../../../../shared/domain/usecases/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/home_section.dart';
import '../repositories/home_repository.dart';

/// Use case for getting home sections
class GetHomeSectionsUseCase implements NoParamsUseCase<List<HomeSection>> {
  final HomeRepository _homeRepository;

  GetHomeSectionsUseCase(this._homeRepository);

  @override
  Future<Result<List<HomeSection>>> call() async {
    try {
      final sections = await _homeRepository.getHomeSections();
      final notificationCounts = await _homeRepository.getNotificationCounts();
      
      // Update sections with notification counts
      final updatedSections = sections.map((section) {
        final count = notificationCounts[section.id] ?? 0;
        return section.copyWith(notificationCount: count > 0 ? count : null);
      }).toList();
      
      return Success(updatedSections);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
} 