import 'package:hushh_agent_app/core/errors/failures.dart';
import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import '../repositories/notification_bidding_repository.dart';

class SaveFcmTokenUseCase implements UseCase<void, SaveFcmTokenParams> {
  final NotificationBiddingRepository _repository;

  SaveFcmTokenUseCase(this._repository);

  @override
  Future<Result<void>> call(SaveFcmTokenParams params) async {
    try {
      await _repository.saveFcmToken(params.token, params.platform);
      return const Success(null);
    } catch (e) {
      return Failed(ServerFailure(e.toString()));
    }
  }
}

class SaveFcmTokenParams {
  final String token;
  final String platform;

  SaveFcmTokenParams({required this.token, required this.platform});
}
