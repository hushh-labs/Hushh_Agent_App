import 'package:get_it/get_it.dart';

// Notification Bidding Feature Imports
import '../data/repository/repository_impl.dart';
import '../domain/repositories/notification_bidding_repository.dart';
import '../domain/usecases/save_fcm_token_usecase.dart';
import '../domain/usecases/get_fcm_token_usecase.dart';
import '../domain/usecases/update_fcm_token_usecase.dart';
import '../domain/usecases/delete_fcm_token_usecase.dart';
import '../domain/usecases/refresh_fcm_token_usecase.dart';
import '../presentation/bloc/notification_bidding_bloc.dart';

/// Service locator instance
final sl = GetIt.instance;

/// Initialize Notification Bidding Feature dependencies using Clean Architecture
void initializeNotificationBiddingFeature() {
  // ===== REPOSITORIES =====
  // Notification Bidding Repository
  sl.registerLazySingleton<NotificationBiddingRepository>(
    () => NotificationBiddingRepositoryImpl(),
  );

  // ===== USE CASES =====
  // Save FCM Token Use Case
  sl.registerLazySingleton<SaveFcmTokenUseCase>(
    () => SaveFcmTokenUseCase(sl<NotificationBiddingRepository>()),
  );

  // Get FCM Token Use Case
  sl.registerLazySingleton<GetFcmTokenUseCase>(
    () => GetFcmTokenUseCase(sl<NotificationBiddingRepository>()),
  );

  // Update FCM Token Use Case
  sl.registerLazySingleton<UpdateFcmTokenUseCase>(
    () => UpdateFcmTokenUseCase(sl<NotificationBiddingRepository>()),
  );

  // Delete FCM Token Use Case
  sl.registerLazySingleton<DeleteFcmTokenUseCase>(
    () => DeleteFcmTokenUseCase(sl<NotificationBiddingRepository>()),
  );

  // Refresh FCM Token Use Case
  sl.registerLazySingleton<RefreshFcmTokenUseCase>(
    () => RefreshFcmTokenUseCase(sl<NotificationBiddingRepository>()),
  );

  // ===== BLOCS =====
  // Notification Bidding BLoC
  sl.registerFactory<NotificationBiddingBloc>(
    () => NotificationBiddingBloc(
      saveFcmTokenUseCase: sl<SaveFcmTokenUseCase>(),
      getFcmTokenUseCase: sl<GetFcmTokenUseCase>(),
      updateFcmTokenUseCase: sl<UpdateFcmTokenUseCase>(),
      deleteFcmTokenUseCase: sl<DeleteFcmTokenUseCase>(),
    ),
  );
}
