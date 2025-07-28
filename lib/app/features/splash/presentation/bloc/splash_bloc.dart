import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/initialize_app_usecase.dart';
import '../../domain/usecases/check_authentication_usecase.dart';
import '../../domain/entities/initialization_result.dart';
import '../../../../../shared/core/usecases/usecase.dart';
import 'splash_event.dart';
import 'splash_state.dart';

/// BLoC for managing splash screen state and initialization flow
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final InitializeAppUseCase initializeAppUseCase;
  final CheckAuthenticationUseCase checkAuthenticationUseCase;

  SplashBloc({
    required this.initializeAppUseCase,
    required this.checkAuthenticationUseCase,
  }) : super(const SplashInitialState()) {
    // Register event handlers
    on<SplashInitializeEvent>(_onInitialize);
    on<SplashCheckAuthEvent>(_onCheckAuth);
    on<SplashLoadAgentProfileEvent>(_onLoadAgentProfile);
    on<SplashUpdateFCMTokenEvent>(_onUpdateFCMToken);
    on<SplashCompleteInitializationEvent>(_onCompleteInitialization);
    on<SplashRetryInitializationEvent>(_onRetryInitialization);
    on<SplashCheckPermissionsEvent>(_onCheckPermissions);
    on<SplashAnimationCompleteEvent>(_onAnimationComplete);
    on<SplashSetupNotificationsEvent>(_onSetupNotifications);
    on<SplashInitializeAnalyticsEvent>(_onInitializeAnalytics);
    on<SplashLoadBusinessDataEvent>(_onLoadBusinessData);
    on<SplashInitializationErrorEvent>(_onInitializationError);
  }

  /// Handle initialization event - main entry point
  Future<void> _onInitialize(
    SplashInitializeEvent event,
    Emitter<SplashState> emit,
  ) async {
    try {
      emit(const SplashInitializingState(
        message: 'Initializing app services...',
        progress: 0.1,
      ));

      // Call the main initialization use case
      final result = await initializeAppUseCase(NoParams());
      
      if (result.isSuccess) {
        if (result.agentProfile != null) {
          // Agent is authenticated, determine next action
          emit(SplashWaitingForAnimationState(
            agentProfile: result.agentProfile,
            nextAction: result.nextAction,
          ));
        } else {
          // No agent found, need to login
          emit(const SplashNoAgentState());
        }
      } else {
        // Initialization failed
        emit(SplashInitializationErrorState(
          errorMessage: result.errorMessage ?? 'Unknown error occurred',
        ));
      }
    } catch (e) {
      emit(SplashInitializationErrorState(
        errorMessage: 'Initialization failed: ${e.toString()}',
      ));
    }
  }

  /// Handle authentication check
  Future<void> _onCheckAuth(
    SplashCheckAuthEvent event,
    Emitter<SplashState> emit,
  ) async {
    try {
      emit(const SplashCheckingAuthState());
      
      final isAuthenticated = await checkAuthenticationUseCase(NoParams());
      
      if (isAuthenticated) {
        // Continue with profile loading
        add(const SplashLoadAgentProfileEvent('current'));
      } else {
        emit(const SplashNoAgentState());
      }
    } catch (e) {
      emit(SplashInitializationErrorState(
        errorMessage: 'Authentication check failed: ${e.toString()}',
      ));
    }
  }

  /// Handle agent profile loading
  Future<void> _onLoadAgentProfile(
    SplashLoadAgentProfileEvent event,
    Emitter<SplashState> emit,
  ) async {
    try {
      emit(const SplashLoadingProfileState());
      
      // TODO: Implement profile loading logic
      // For now, emit a placeholder state
      emit(const SplashInitializingState(
        message: 'Loading agent profile...',
        progress: 0.7,
      ));
      
      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      add(const SplashCompleteInitializationEvent());
    } catch (e) {
      emit(SplashInitializationErrorState(
        errorMessage: 'Failed to load agent profile: ${e.toString()}',
      ));
    }
  }

  /// Handle FCM token update
  Future<void> _onUpdateFCMToken(
    SplashUpdateFCMTokenEvent event,
    Emitter<SplashState> emit,
  ) async {
    try {
      // TODO: Implement FCM token update logic
      print('🔄 [BLOC] Updating FCM token for agent: ${event.agentId}');
    } catch (e) {
      print('❌ [BLOC] Error updating FCM token: $e');
    }
  }

  /// Handle initialization completion
  Future<void> _onCompleteInitialization(
    SplashCompleteInitializationEvent event,
    Emitter<SplashState> emit,
  ) async {
    try {
      emit(const SplashInitializingState(
        message: 'Completing setup...',
        progress: 1.0,
      ));

      // Wait a bit for the progress to show
      await Future.delayed(const Duration(milliseconds: 300));

      // For now, navigate to auth as default
      emit(const SplashInitializationCompleteState(
        nextAction: NextAction.navigateToAuth,
      ));
    } catch (e) {
      emit(SplashInitializationErrorState(
        errorMessage: 'Failed to complete initialization: ${e.toString()}',
      ));
    }
  }

  /// Handle retry initialization
  Future<void> _onRetryInitialization(
    SplashRetryInitializationEvent event,
    Emitter<SplashState> emit,
  ) async {
    // Reset to initial state and try again
    emit(const SplashInitialState());
    add(const SplashInitializeEvent());
  }

  /// Handle permissions check
  Future<void> _onCheckPermissions(
    SplashCheckPermissionsEvent event,
    Emitter<SplashState> emit,
  ) async {
    try {
      emit(const SplashCheckingPermissionsState());
      
      // TODO: Implement permission checking logic
      print('🔄 [BLOC] Checking permissions');
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('❌ [BLOC] Error checking permissions: $e');
    }
  }

  /// Handle animation completion
  Future<void> _onAnimationComplete(
    SplashAnimationCompleteEvent event,
    Emitter<SplashState> emit,
  ) async {
    // If we're waiting for animation, proceed with navigation
    if (state is SplashWaitingForAnimationState) {
      final currentState = state as SplashWaitingForAnimationState;
      emit(SplashNavigatingState(
        nextAction: currentState.nextAction,
        agentProfile: currentState.agentProfile,
      ));
    }
  }

  /// Handle notifications setup
  Future<void> _onSetupNotifications(
    SplashSetupNotificationsEvent event,
    Emitter<SplashState> emit,
  ) async {
    try {
      emit(const SplashSetupNotificationsState());
      
      // TODO: Implement notification setup logic
      print('🔄 [BLOC] Setting up notifications');
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('❌ [BLOC] Error setting up notifications: $e');
    }
  }

  /// Handle analytics initialization
  Future<void> _onInitializeAnalytics(
    SplashInitializeAnalyticsEvent event,
    Emitter<SplashState> emit,
  ) async {
    try {
      emit(const SplashInitializingAnalyticsState());
      
      // TODO: Implement analytics initialization logic
      print('🔄 [BLOC] Initializing analytics for: ${event.agentId}');
      
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      print('❌ [BLOC] Error initializing analytics: $e');
    }
  }

  /// Handle business data loading
  Future<void> _onLoadBusinessData(
    SplashLoadBusinessDataEvent event,
    Emitter<SplashState> emit,
  ) async {
    try {
      emit(const SplashLoadingBusinessDataState());
      
      // TODO: Implement business data loading logic
      print('🔄 [BLOC] Loading business data for: ${event.agentId}');
      
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('❌ [BLOC] Error loading business data: $e');
    }
  }

  /// Handle initialization error
  Future<void> _onInitializationError(
    SplashInitializationErrorEvent event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashInitializationErrorState(
      errorMessage: event.error,
    ));
  }
} 