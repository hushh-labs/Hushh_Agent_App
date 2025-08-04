import 'package:hushh_agent_app/core/errors/failures.dart';
import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import '../repositories/notification_bidding_repository.dart';

class DeleteFcmTokenUseCase implements UseCase<void, void> {
  final NotificationBiddingRepository _repository;

  DeleteFcmTokenUseCase(this._repository);

  @override
  Future<Result<void>> call(void params) async {
    try {
      await _repository.deleteFcmToken();
      return const Success(null);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
}
