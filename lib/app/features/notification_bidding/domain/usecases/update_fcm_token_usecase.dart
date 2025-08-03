import 'package:hushh_agent_app/core/errors/failures.dart';
import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import '../repositories/notification_bidding_repository.dart';

class UpdateFcmTokenUseCase implements UseCase<void, UpdateFcmTokenParams> {
  final NotificationBiddingRepository _repository;

  UpdateFcmTokenUseCase(this._repository);

  @override
  Future<Result<void>> call(UpdateFcmTokenParams params) async {
    try {
      await _repository.updateFcmToken(params.token);
      return const Success(null);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
}

class UpdateFcmTokenParams {
  final String token;

  UpdateFcmTokenParams({required this.token});
}
