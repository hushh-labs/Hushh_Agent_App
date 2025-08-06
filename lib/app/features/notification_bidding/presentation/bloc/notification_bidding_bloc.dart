import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/fcm_token.dart';
import '../../domain/usecases/save_fcm_token_usecase.dart';
import '../../domain/usecases/get_fcm_token_usecase.dart';
import '../../domain/usecases/update_fcm_token_usecase.dart';
import '../../domain/usecases/delete_fcm_token_usecase.dart';
import '../../../../../shared/domain/usecases/base_usecase.dart';

// Events
abstract class NotificationBiddingEvent {}

class InitializeFcmTokenEvent extends NotificationBiddingEvent {
  final String platform;
  InitializeFcmTokenEvent(this.platform);
}

class SaveFcmTokenEvent extends NotificationBiddingEvent {
  final String token;
  final String platform;
  SaveFcmTokenEvent({required this.token, required this.platform});
}

class GetFcmTokenEvent extends NotificationBiddingEvent {}

class UpdateFcmTokenEvent extends NotificationBiddingEvent {
  final String token;
  UpdateFcmTokenEvent(this.token);
}

class DeleteFcmTokenEvent extends NotificationBiddingEvent {}

// States
abstract class NotificationBiddingState {}

class NotificationBiddingInitialState extends NotificationBiddingState {}

class NotificationBiddingLoadingState extends NotificationBiddingState {}

class FcmTokenInitializingState extends NotificationBiddingState {}

class FcmTokenInitializedState extends NotificationBiddingState {
  final String? token;
  final String platform;
  FcmTokenInitializedState({this.token, required this.platform});
}

class FcmTokenSavingState extends NotificationBiddingState {}

class FcmTokenSavedState extends NotificationBiddingState {
  final String token;
  final String platform;
  FcmTokenSavedState({required this.token, required this.platform});
}

class FcmTokenSaveFailureState extends NotificationBiddingState {
  final String message;
  FcmTokenSaveFailureState(this.message);
}

class FcmTokenGettingState extends NotificationBiddingState {}

class FcmTokenRetrievedState extends NotificationBiddingState {
  final FcmToken? fcmToken;
  FcmTokenRetrievedState(this.fcmToken);
}

class FcmTokenGetFailureState extends NotificationBiddingState {
  final String message;
  FcmTokenGetFailureState(this.message);
}

class FcmTokenUpdatingState extends NotificationBiddingState {}

class FcmTokenUpdatedState extends NotificationBiddingState {
  final String token;
  FcmTokenUpdatedState(this.token);
}

class FcmTokenUpdateFailureState extends NotificationBiddingState {
  final String message;
  FcmTokenUpdateFailureState(this.message);
}

class FcmTokenDeletingState extends NotificationBiddingState {}

class FcmTokenDeletedState extends NotificationBiddingState {}

class FcmTokenDeleteFailureState extends NotificationBiddingState {
  final String message;
  FcmTokenDeleteFailureState(this.message);
}

class NotificationBiddingBloc
    extends Bloc<NotificationBiddingEvent, NotificationBiddingState> {
  // Use cases
  final SaveFcmTokenUseCase _saveFcmTokenUseCase;
  final GetFcmTokenUseCase _getFcmTokenUseCase;
  final UpdateFcmTokenUseCase _updateFcmTokenUseCase;
  final DeleteFcmTokenUseCase _deleteFcmTokenUseCase;

  NotificationBiddingBloc({
    required SaveFcmTokenUseCase saveFcmTokenUseCase,
    required GetFcmTokenUseCase getFcmTokenUseCase,
    required UpdateFcmTokenUseCase updateFcmTokenUseCase,
    required DeleteFcmTokenUseCase deleteFcmTokenUseCase,
  })  : _saveFcmTokenUseCase = saveFcmTokenUseCase,
        _getFcmTokenUseCase = getFcmTokenUseCase,
        _updateFcmTokenUseCase = updateFcmTokenUseCase,
        _deleteFcmTokenUseCase = deleteFcmTokenUseCase,
        super(NotificationBiddingInitialState()) {
    on<InitializeFcmTokenEvent>(onInitializeFcmTokenEvent);
    on<SaveFcmTokenEvent>(onSaveFcmTokenEvent);
    on<GetFcmTokenEvent>(onGetFcmTokenEvent);
    on<UpdateFcmTokenEvent>(onUpdateFcmTokenEvent);
    on<DeleteFcmTokenEvent>(onDeleteFcmTokenEvent);
  }

  FutureOr<void> onInitializeFcmTokenEvent(
    InitializeFcmTokenEvent event,
    Emitter<NotificationBiddingState> emit,
  ) async {
    print(
        '🔄 [NOTIFICATION] Initializing FCM token for platform: ${event.platform}');
    emit(FcmTokenInitializingState());

    try {
      // Check if user is authenticated
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(FcmTokenInitializedState(token: null, platform: event.platform));
        return;
      }

      // Get existing FCM token
      final result = await _getFcmTokenUseCase(null);

      if (result is Success<FcmToken?>) {
        final fcmToken = result.data;
        emit(FcmTokenInitializedState(
          token: fcmToken?.token,
          platform: event.platform,
        ));
      } else if (result is Failed<FcmToken?>) {
        print(
            '⚠️ [NOTIFICATION] Failed to get existing FCM token: ${result.failure.message}');
        emit(FcmTokenInitializedState(token: null, platform: event.platform));
      }
    } catch (e) {
      print('❌ [NOTIFICATION] Error initializing FCM token: $e');
      emit(FcmTokenInitializedState(token: null, platform: event.platform));
    }
  }

  FutureOr<void> onSaveFcmTokenEvent(
    SaveFcmTokenEvent event,
    Emitter<NotificationBiddingState> emit,
  ) async {
    print('🔄 [NOTIFICATION] Saving FCM token: ${event.token}');
    emit(FcmTokenSavingState());

    try {
      final params = SaveFcmTokenParams(
        token: event.token,
        platform: event.platform,
      );

      final result = await _saveFcmTokenUseCase(params);

      if (result is Success<void>) {
        emit(FcmTokenSavedState(
          token: event.token,
          platform: event.platform,
        ));
      } else if (result is Failed<void>) {
        emit(FcmTokenSaveFailureState(result.failure.message));
      }
    } catch (e) {
      emit(FcmTokenSaveFailureState(
          'Failed to save FCM token: ${e.toString()}'));
    }
  }

  FutureOr<void> onGetFcmTokenEvent(
    GetFcmTokenEvent event,
    Emitter<NotificationBiddingState> emit,
  ) async {
    print('🔄 [NOTIFICATION] Getting FCM token');
    emit(FcmTokenGettingState());

    try {
      final result = await _getFcmTokenUseCase(null);

      if (result is Success<FcmToken?>) {
        emit(FcmTokenRetrievedState(result.data));
      } else if (result is Failed<FcmToken?>) {
        emit(FcmTokenGetFailureState(result.failure.message));
      }
    } catch (e) {
      emit(FcmTokenGetFailureState('Failed to get FCM token: ${e.toString()}'));
    }
  }

  FutureOr<void> onUpdateFcmTokenEvent(
    UpdateFcmTokenEvent event,
    Emitter<NotificationBiddingState> emit,
  ) async {
    print('🔄 [NOTIFICATION] Updating FCM token: ${event.token}');
    emit(FcmTokenUpdatingState());

    try {
      final params = UpdateFcmTokenParams(token: event.token);

      final result = await _updateFcmTokenUseCase(params);

      if (result is Success<void>) {
        emit(FcmTokenUpdatedState(event.token));
      } else if (result is Failed<void>) {
        emit(FcmTokenUpdateFailureState(result.failure.message));
      }
    } catch (e) {
      emit(FcmTokenUpdateFailureState(
          'Failed to update FCM token: ${e.toString()}'));
    }
  }

  FutureOr<void> onDeleteFcmTokenEvent(
    DeleteFcmTokenEvent event,
    Emitter<NotificationBiddingState> emit,
  ) async {
    print('🔄 [NOTIFICATION] Deleting FCM token');
    emit(FcmTokenDeletingState());

    try {
      final result = await _deleteFcmTokenUseCase(null);

      if (result is Success<void>) {
        emit(FcmTokenDeletedState());
      } else if (result is Failed<void>) {
        emit(FcmTokenDeleteFailureState(result.failure.message));
      }
    } catch (e) {
      emit(FcmTokenDeleteFailureState(
          'Failed to delete FCM token: ${e.toString()}'));
    }
  }
}
