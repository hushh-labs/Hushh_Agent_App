import 'package:hushh_agent_app/core/errors/failures.dart';
import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import '../entities/fcm_token.dart';
import '../repositories/notification_bidding_repository.dart';

class GetFcmTokenUseCase implements UseCase<FcmToken?, void> {
  final NotificationBiddingRepository _repository;

  GetFcmTokenUseCase(this._repository);

  @override
  Future<Result<FcmToken?>> call(void params) async {
    try {
      final token = await _repository.getFcmToken();
      return Success(token);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
}
