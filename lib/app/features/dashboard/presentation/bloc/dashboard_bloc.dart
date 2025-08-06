import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  
  @override
  List<Object> get props => [];
}

class LoadDashboardEvent extends DashboardEvent {
  const LoadDashboardEvent();
}

class RefreshDashboardEvent extends DashboardEvent {
  const RefreshDashboardEvent();
}

class CompleteProfileEvent extends DashboardEvent {
  const CompleteProfileEvent();
}

class SelectTabEvent extends DashboardEvent {
  final DashboardTab tab;

  const SelectTabEvent(this.tab);

  @override
  List<Object> get props => [tab];
}

class LoadServicesEvent extends DashboardEvent {
  const LoadServicesEvent();
}

class LoadCustomersEvent extends DashboardEvent {
  const LoadCustomersEvent();
}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();
  
  @override
  List<Object> get props => [];
}

class DashboardInitialState extends DashboardState {
  const DashboardInitialState();
}

class DashboardLoadingState extends DashboardState {
  const DashboardLoadingState();
}

class DashboardLoadedState extends DashboardState {
  final double walletBalance;
  final bool isProfileComplete;
  final List<QuickInsightItem> insights;
  final DashboardTab selectedTab;
  final List<ServiceItem> services;
  final List<CustomerItem> customers;

  const DashboardLoadedState({
    required this.walletBalance,
    required this.isProfileComplete,
    required this.insights,
    required this.selectedTab,
    required this.services,
    required this.customers,
  });

  @override
  List<Object> get props => [
    walletBalance,
    isProfileComplete,
    insights,
    selectedTab,
    services,
    customers,
  ];

  DashboardLoadedState copyWith({
    double? walletBalance,
    bool? isProfileComplete,
    List<QuickInsightItem>? insights,
    DashboardTab? selectedTab,
    List<ServiceItem>? services,
    List<CustomerItem>? customers,
  }) {
    return DashboardLoadedState(
      walletBalance: walletBalance ?? this.walletBalance,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      insights: insights ?? this.insights,
      selectedTab: selectedTab ?? this.selectedTab,
      services: services ?? this.services,
      customers: customers ?? this.customers,
    );
  }
}

class DashboardErrorState extends DashboardState {
  final String message;

  const DashboardErrorState(this.message);

  @override
  List<Object> get props => [message];
}

class ProfileCompletingState extends DashboardState {
  const ProfileCompletingState();
}

// Data Models
enum DashboardTab { services, customers }

class QuickInsightItem {
  final String id;
  final String title;
  final String iconName;
  final String value;
  final VoidCallback? onTap;

  const QuickInsightItem({
    required this.id,
    required this.title,
    required this.iconName,
    required this.value,
    this.onTap,
  });
}

class ServiceItem {
  final String id;
  final String name;
  final String description;
  final String status;

  const ServiceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
  });
}

class CustomerItem {
  final String id;
  final String name;
  final String email;
  final String status;

  const CustomerItem({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
  });
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardInitialState()) {
    on<LoadDashboardEvent>(_onLoadDashboard);
    on<RefreshDashboardEvent>(_onRefreshDashboard);
    on<CompleteProfileEvent>(_onCompleteProfile);
    on<SelectTabEvent>(_onSelectTab);
    on<LoadServicesEvent>(_onLoadServices);
    on<LoadCustomersEvent>(_onLoadCustomers);
  }

  void _onLoadDashboard(LoadDashboardEvent event, Emitter<DashboardState> emit) async {
    emit(const DashboardLoadingState());
    
    try {
      // TODO: Implement actual dashboard data loading
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock dashboard data
      final insights = [
        const QuickInsightItem(
          id: 'new_customers',
          title: 'New Customers',
          iconName: 'people',
          value: '', // Empty as requested
        ),
        const         QuickInsightItem(
          id: 'logbooks_products',
          title: 'Lookbooks &\nProducts',
          iconName: 'inventory',
          value: '', // Empty as requested
        ),
        const QuickInsightItem(
          id: 'total_orders',
          title: 'Total Orders',
          iconName: 'shopping_cart',
          value: '', // Empty as requested
        ),
        const QuickInsightItem(
          id: 'total_revenue',
          title: 'Total Revenue',
          iconName: 'attach_money',
          value: '', // Empty as requested
        ),
      ];
      
      emit(DashboardLoadedState(
        walletBalance: 1250.00,
        isProfileComplete: true, // Changed to true to show congratulations
        insights: insights,
        selectedTab: DashboardTab.services,
        services: [],
        customers: [],
      ));
    } catch (e) {
      emit(DashboardErrorState('Failed to load dashboard: ${e.toString()}'));
    }
  }

  void _onRefreshDashboard(RefreshDashboardEvent event, Emitter<DashboardState> emit) async {
    if (state is DashboardLoadedState) {
      final currentState = state as DashboardLoadedState;
      
      try {
        // TODO: Implement actual refresh logic
        await Future.delayed(const Duration(milliseconds: 300));
        
        // For now, just emit the same state to simulate refresh
        emit(currentState);
      } catch (e) {
        emit(DashboardErrorState('Failed to refresh dashboard: ${e.toString()}'));
      }
    }
  }

  void _onCompleteProfile(CompleteProfileEvent event, Emitter<DashboardState> emit) async {
    if (state is DashboardLoadedState) {
      final currentState = state as DashboardLoadedState;
      emit(const ProfileCompletingState());
      
      try {
        // TODO: Navigate to profile completion flow
        await Future.delayed(const Duration(milliseconds: 500));
        
        emit(currentState.copyWith(isProfileComplete: true));
      } catch (e) {
        emit(DashboardErrorState('Failed to complete profile: ${e.toString()}'));
      }
    }
  }

  void _onSelectTab(SelectTabEvent event, Emitter<DashboardState> emit) async {
    if (state is DashboardLoadedState) {
      final currentState = state as DashboardLoadedState;
      
      emit(currentState.copyWith(selectedTab: event.tab));
      
      // Load data based on selected tab
      if (event.tab == DashboardTab.services) {
        add(const LoadServicesEvent());
      } else {
        add(const LoadCustomersEvent());
      }
    }
  }

  void _onLoadServices(LoadServicesEvent event, Emitter<DashboardState> emit) async {
    if (state is DashboardLoadedState) {
      final currentState = state as DashboardLoadedState;
      
      try {
        // TODO: Implement actual services loading
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Mock empty services for now
        emit(currentState.copyWith(services: []));
      } catch (e) {
        emit(DashboardErrorState('Failed to load services: ${e.toString()}'));
      }
    }
  }

  void _onLoadCustomers(LoadCustomersEvent event, Emitter<DashboardState> emit) async {
    if (state is DashboardLoadedState) {
      final currentState = state as DashboardLoadedState;
      
      try {
        // TODO: Implement actual customers loading
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Remove mock customers - return empty list
        emit(currentState.copyWith(customers: []));
              } catch (e) {
          emit(DashboardErrorState('Failed to load customers: ${e.toString()}'));
        }
      }
    }
  }
