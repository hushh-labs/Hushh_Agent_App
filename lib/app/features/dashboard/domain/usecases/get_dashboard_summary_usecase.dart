import '../../../../../shared/domain/usecases/base_usecase.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/dashboard_data.dart';
import '../repositories/dashboard_repository.dart';

/// Use case for getting dashboard summary
class GetDashboardSummaryUseCase implements NoParamsUseCase<DashboardSummary> {
  final DashboardRepository _dashboardRepository;

  GetDashboardSummaryUseCase(this._dashboardRepository);

  @override
  Future<Result<DashboardSummary>> call() async {
    try {
      final summary = await _dashboardRepository.getDashboardSummary();
      return Success(summary);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
} 