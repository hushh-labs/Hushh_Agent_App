import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class NavigateToTabEvent extends HomeEvent {
  final int tabIndex;

  const NavigateToTabEvent(this.tabIndex);

  @override
  List<Object> get props => [tabIndex];
}

class InitializeHomeEvent extends HomeEvent {}

// States
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitialState extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeLoadedState extends HomeState {
  final int currentTabIndex;

  const HomeLoadedState({this.currentTabIndex = 0});

  @override
  List<Object> get props => [currentTabIndex];

  HomeLoadedState copyWith({int? currentTabIndex}) {
    return HomeLoadedState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
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
  HomeBloc() : super(HomeInitialState()) {
    on<InitializeHomeEvent>(_onInitializeHome);
    on<NavigateToTabEvent>(_onNavigateToTab);
  }

  FutureOr<void> _onInitializeHome(
    InitializeHomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoadingState());
    
    try {
      // Initialize home with wallet as default tab (index 0)
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const HomeLoadedState(currentTabIndex: 0));
    } catch (e) {
      emit(HomeErrorState('Failed to initialize home: ${e.toString()}'));
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
} 