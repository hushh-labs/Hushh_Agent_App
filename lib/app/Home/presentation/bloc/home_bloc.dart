import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/home_section.dart';
import '../../domain/usecases/get_home_sections_usecase.dart';
import '../../domain/usecases/initialize_home_usecase.dart';
import '../../../../shared/domain/usecases/base_usecase.dart';
import '../../../../shared/utils/app_local_storage.dart';
import '../../../features/notification_bidding/domain/usecases/refresh_fcm_token_usecase.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class InitializeHomeEvent extends HomeEvent {
  final String? preferredSection;

  const InitializeHomeEvent({this.preferredSection});

  @override
  List<Object> get props => [preferredSection ?? ''];
}

class CheckAuthenticationEvent extends HomeEvent {}

class LoadHomeSectionsEvent extends HomeEvent {}

class NavigateToTabEvent extends HomeEvent {
  final int tabIndex;

  const NavigateToTabEvent(this.tabIndex);

  @override
  List<Object> get props => [tabIndex];
}

class RefreshNotificationCountsEvent extends HomeEvent {}

class LogoutEvent extends HomeEvent {}

class AuthStateChangedEvent extends HomeEvent {
  final User? user;

  const AuthStateChangedEvent(this.user);

  @override
  List<Object> get props => [user?.uid ?? 'null'];
}

// States
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitialState extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeAuthenticationRequiredState extends HomeState {
  final String? message;

  const HomeAuthenticationRequiredState({this.message});

  @override
  List<Object> get props => [message ?? ''];
}

class HomeLoadedState extends HomeState {
  final int currentTabIndex;
  final List<HomeSection> sections;
  final User? currentUser;

  const HomeLoadedState({
    required this.currentTabIndex,
    required this.sections,
    this.currentUser,
  });

  @override
  List<Object> get props => [currentTabIndex, sections, currentUser?.uid ?? ''];

  HomeLoadedState copyWith({
    int? currentTabIndex,
    List<HomeSection>? sections,
    User? currentUser,
  }) {
    return HomeLoadedState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      sections: sections ?? this.sections,
      currentUser: currentUser ?? this.currentUser,
    );
  }
}

class HomeErrorState extends HomeState {
  final String message;

  const HomeErrorState(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeSectionsUseCase _getHomeSectionsUseCase;
  final InitializeHomeUseCase _initializeHomeUseCase;
  final RefreshFcmTokenUseCase _refreshFcmTokenUseCase;
  final FirebaseAuth _firebaseAuth;
  late StreamSubscription<User?> _authStateSubscription;

  HomeBloc({
    required GetHomeSectionsUseCase getHomeSectionsUseCase,
    required InitializeHomeUseCase initializeHomeUseCase,
    required RefreshFcmTokenUseCase refreshFcmTokenUseCase,
    FirebaseAuth? firebaseAuth,
  })  : _getHomeSectionsUseCase = getHomeSectionsUseCase,
        _initializeHomeUseCase = initializeHomeUseCase,
        _refreshFcmTokenUseCase = refreshFcmTokenUseCase,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(HomeInitialState()) {
    on<InitializeHomeEvent>(_onInitializeHome);
    on<CheckAuthenticationEvent>(_onCheckAuthentication);
    on<LoadHomeSectionsEvent>(_onLoadHomeSections);
    on<NavigateToTabEvent>(_onNavigateToTab);
    on<RefreshNotificationCountsEvent>(_onRefreshNotificationCounts);
    on<LogoutEvent>(_onLogout);
    on<AuthStateChangedEvent>(_onAuthStateChanged);

    // Listen to Firebase Auth state changes
    _authStateSubscription = _firebaseAuth.authStateChanges().listen((user) {
      add(AuthStateChangedEvent(user));
    });
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }

  FutureOr<void> _onInitializeHome(
    InitializeHomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Skip loading state and directly check authentication
    try {
      // Directly check authentication without emitting loading state
      add(CheckAuthenticationEvent());
    } catch (e) {
      emit(HomeErrorState('Failed to initialize home: ${e.toString()}'));
    }
  }

  FutureOr<void> _onCheckAuthentication(
    CheckAuthenticationEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      final isGuestMode = AppLocalStorage.isGuestMode;

      // Allow access if user is authenticated OR in guest mode
      if (currentUser == null && !isGuestMode) {
        // User not authenticated and not in guest mode, require login
        emit(const HomeAuthenticationRequiredState(
          message: 'Please log in to continue',
        ));
        return;
      }

      // User is authenticated OR in guest mode, load sections
      final result = await _getHomeSectionsUseCase();

      if (result is Success<List<HomeSection>>) {
        final sections = result.data;

        // Refresh FCM token if user is authenticated (not guest mode)
        if (currentUser != null) {
          try {
            await _refreshFcmTokenUseCase(null);
            print('✅ [HOME] FCM token refreshed on app open');
          } catch (e) {
            print('⚠️ [HOME] Failed to refresh FCM token on app open: $e');
            // Continue with app loading even if FCM refresh fails
          }
        }

        emit(HomeLoadedState(
          currentTabIndex: 0,
          sections: sections,
          currentUser: currentUser, // Will be null for guest mode
        ));
      } else if (result is Failed) {
        emit(HomeErrorState('Failed to load home sections'));
      }
    } catch (e) {
      emit(HomeErrorState('Authentication check failed: ${e.toString()}'));
    }
  }

  FutureOr<void> _onLoadHomeSections(
    LoadHomeSectionsEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final result = await _getHomeSectionsUseCase();

      if (result is Success<List<HomeSection>>) {
        final sections = result.data;
        final currentIndex = state is HomeLoadedState
            ? (state as HomeLoadedState).currentTabIndex
            : 0;
        final currentUser = _firebaseAuth.currentUser;

        emit(HomeLoadedState(
          currentTabIndex: currentIndex,
          sections: sections,
          currentUser: currentUser,
        ));
      } else if (result is Failed) {
        emit(HomeErrorState('Failed to load home sections'));
      }
    } catch (e) {
      emit(HomeErrorState('Failed to load home sections: ${e.toString()}'));
    }
  }

  FutureOr<void> _onNavigateToTab(
    NavigateToTabEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoadedState) {
      final currentState = state as HomeLoadedState;
      emit(currentState.copyWith(currentTabIndex: event.tabIndex));
    }
  }

  FutureOr<void> _onRefreshNotificationCounts(
    RefreshNotificationCountsEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Refresh notification counts by reloading sections
    add(LoadHomeSectionsEvent());
  }

  FutureOr<void> _onLogout(
    LogoutEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      await _firebaseAuth.signOut();
      emit(const HomeAuthenticationRequiredState(
        message: 'Logged out successfully',
      ));
    } catch (e) {
      emit(HomeErrorState('Logout failed: ${e.toString()}'));
    }
  }

  FutureOr<void> _onAuthStateChanged(
    AuthStateChangedEvent event,
    Emitter<HomeState> emit,
  ) async {
    final user = event.user;
    final isGuestMode = AppLocalStorage.isGuestMode;

    if (user == null && !isGuestMode) {
      // User signed out and not in guest mode - require authentication
      emit(const HomeAuthenticationRequiredState(
        message: 'Authentication required',
      ));
    } else if (user != null) {
      // User signed in, reload home if we're in auth required state
      if (state is HomeAuthenticationRequiredState) {
        add(const InitializeHomeEvent());
      } else if (state is HomeLoadedState) {
        // Update current user in loaded state
        final currentState = state as HomeLoadedState;
        emit(currentState.copyWith(currentUser: user));
      }
    }
    // If user == null && isGuestMode, do nothing - keep current state
  }
}
