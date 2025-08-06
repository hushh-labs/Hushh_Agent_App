import '../../../../../shared/domain/usecases/base_usecase.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/dashboard_data.dart';
import '../repositories/dashboard_repository.dart';

/// Parameters for getting recent activities
class GetRecentActivitiesParams extends UseCaseParams {
  final int limit;

  const GetRecentActivitiesParams({this.limit = 10});

  @override
  List<Object> get props => [limit];
}

/// Use case for getting recent activities
class GetRecentActivitiesUseCase implements UseCase<List<ActivityItem>, GetRecentActivitiesParams> {
  final DashboardRepository _dashboardRepository;

  GetRecentActivitiesUseCase(this._dashboardRepository);

  @override
  Future<Result<List<ActivityItem>>> call(GetRecentActivitiesParams params) async {
    try {
      final activities = await _dashboardRepository.getRecentActivities(
        limit: params.limit,
      );
      return Success(activities);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
} 