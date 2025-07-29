import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hushh_agent_app/shared/domain/usecases/base_usecase.dart';
import '../../domain/entities/hushh_agent.dart';
import '../../domain/entities/agent_category.dart';
import '../../domain/entities/agent_brand.dart';
import '../../domain/usecases/update_agent_profile_usecase.dart';
import '../../domain/usecases/get_agent_categories_usecase.dart';
import '../../domain/usecases/get_agent_brands_usecase.dart';

// Events
abstract class ProfileCompletionEvent extends Equatable {
  const ProfileCompletionEvent();
  
  @override
  List<Object?> get props => [];
}

class InitializeProfileCompletionEvent extends ProfileCompletionEvent {
  final String agentId;
  
  const InitializeProfileCompletionEvent({required this.agentId});
  
  @override
  List<Object?> get props => [agentId];
}

class LoadCategoriesEvent extends ProfileCompletionEvent {}

class LoadBrandsEvent extends ProfileCompletionEvent {
  final String categoryId;
  
  const LoadBrandsEvent({required this.categoryId});
  
  @override
  List<Object?> get props => [categoryId];
}

class UpdateBasicInfoEvent extends ProfileCompletionEvent {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? reasonForUsingHushh;
  
  const UpdateBasicInfoEvent({
    this.firstName,
    this.lastName,
    this.email,
    this.reasonForUsingHushh,
  });
  
  @override
  List<Object?> get props => [firstName, lastName, email, reasonForUsingHushh];
}

class SelectCategoryEvent extends ProfileCompletionEvent {
  final String categoryId;
  
  const SelectCategoryEvent({required this.categoryId});
  
  @override
  List<Object?> get props => [categoryId];
}

class SelectBrandEvent extends ProfileCompletionEvent {
  final String brandId;
  
  const SelectBrandEvent({required this.brandId});
  
  @override
  List<Object?> get props => [brandId];
}

class CompleteProfileEvent extends ProfileCompletionEvent {}

// States
abstract class ProfileCompletionState extends Equatable {
  const ProfileCompletionState();
  
  @override
  List<Object?> get props => [];
}

class ProfileCompletionInitialState extends ProfileCompletionState {}

class ProfileCompletionLoadingState extends ProfileCompletionState {}

class ProfileCompletionLoadedState extends ProfileCompletionState {
  final String agentId;
  final OnboardStatus currentStep;
  final List<AgentCategory> categories;
  final List<AgentBrand> brands;
  final String? selectedCategoryId;
  final String? selectedBrandId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? reasonForUsingHushh;
  
  const ProfileCompletionLoadedState({
    required this.agentId,
    required this.currentStep,
    this.categories = const [],
    this.brands = const [],
    this.selectedCategoryId,
    this.selectedBrandId,
    this.firstName,
    this.lastName,
    this.email,
    this.reasonForUsingHushh,
  });
  
  @override
  List<Object?> get props => [
    agentId,
    currentStep,
    categories,
    brands,
    selectedCategoryId,
    selectedBrandId,
    firstName,
    lastName,
    email,
    reasonForUsingHushh,
  ];
  
  ProfileCompletionLoadedState copyWith({
    String? agentId,
    OnboardStatus? currentStep,
    List<AgentCategory>? categories,
    List<AgentBrand>? brands,
    String? selectedCategoryId,
    String? selectedBrandId,
    String? firstName,
    String? lastName,
    String? email,
    String? reasonForUsingHushh,
  }) {
    return ProfileCompletionLoadedState(
      agentId: agentId ?? this.agentId,
      currentStep: currentStep ?? this.currentStep,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedBrandId: selectedBrandId ?? this.selectedBrandId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      reasonForUsingHushh: reasonForUsingHushh ?? this.reasonForUsingHushh,
    );
  }
}

class ProfileCompletionUpdatingState extends ProfileCompletionState {}

class ProfileCompletionErrorState extends ProfileCompletionState {
  final String message;
  
  const ProfileCompletionErrorState({required this.message});
  
  @override
  List<Object?> get props => [message];
}

class ProfileCompletionCompletedState extends ProfileCompletionState {}

// BLoC
class ProfileCompletionBloc extends Bloc<ProfileCompletionEvent, ProfileCompletionState> {
  final UpdateAgentProfileUseCase _updateProfileUseCase;
  final GetAgentCategoriesUseCase _getCategoriesUseCase;
  final GetAgentBrandsUseCase _getBrandsUseCase;
  
  ProfileCompletionBloc({
    required UpdateAgentProfileUseCase updateProfileUseCase,
    required GetAgentCategoriesUseCase getCategoriesUseCase,
    required GetAgentBrandsUseCase getBrandsUseCase,
  }) : _updateProfileUseCase = updateProfileUseCase,
       _getCategoriesUseCase = getCategoriesUseCase,
       _getBrandsUseCase = getBrandsUseCase,
       super(ProfileCompletionInitialState()) {
    
    on<InitializeProfileCompletionEvent>(_onInitializeProfileCompletion);
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<LoadBrandsEvent>(_onLoadBrands);
    on<UpdateBasicInfoEvent>(_onUpdateBasicInfo);
    on<SelectCategoryEvent>(_onSelectCategory);
    on<SelectBrandEvent>(_onSelectBrand);
    on<CompleteProfileEvent>(_onCompleteProfile);
  }
  
  void _onInitializeProfileCompletion(
    InitializeProfileCompletionEvent event,
    Emitter<ProfileCompletionState> emit,
  ) async {
    emit(ProfileCompletionLoadingState());
    
    try {
      emit(ProfileCompletionLoadedState(
        agentId: event.agentId,
        currentStep: OnboardStatus.initial,
      ));
      
      // Load initial categories
      add(LoadCategoriesEvent());
    } catch (e) {
      emit(ProfileCompletionErrorState(message: e.toString()));
    }
  }
  
  void _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<ProfileCompletionState> emit,
  ) async {
    if (state is ProfileCompletionLoadedState) {
      final currentState = state as ProfileCompletionLoadedState;
      
      try {
        final result = await _getCategoriesUseCase(const NoParams());
        
        switch (result) {
          case Success<List<AgentCategory>>():
            emit(currentState.copyWith(categories: result.data));
          case Failed<List<AgentCategory>>():
            emit(ProfileCompletionErrorState(message: result.failure.message));
        }
      } catch (e) {
        emit(ProfileCompletionErrorState(message: e.toString()));
      }
    }
  }
  
  void _onLoadBrands(
    LoadBrandsEvent event,
    Emitter<ProfileCompletionState> emit,
  ) async {
    if (state is ProfileCompletionLoadedState) {
      final currentState = state as ProfileCompletionLoadedState;
      
      try {
        final result = await _getBrandsUseCase(GetAgentBrandsParams(categoryId: event.categoryId));
        
        switch (result) {
          case Success<List<AgentBrand>>():
            emit(currentState.copyWith(brands: result.data));
          case Failed<List<AgentBrand>>():
            emit(ProfileCompletionErrorState(message: result.failure.message));
        }
      } catch (e) {
        emit(ProfileCompletionErrorState(message: e.toString()));
      }
    }
  }
  
  void _onUpdateBasicInfo(
    UpdateBasicInfoEvent event,
    Emitter<ProfileCompletionState> emit,
  ) async {
    if (state is ProfileCompletionLoadedState) {
      final currentState = state as ProfileCompletionLoadedState;
      
      emit(ProfileCompletionUpdatingState());
      
      try {
        final params = UpdateAgentProfileParams(
          agentId: currentState.agentId,
          firstName: event.firstName,
          lastName: event.lastName,
          email: event.email,
          selectedReasonForUsingHushh: event.reasonForUsingHushh,
          onboardStatus: OnboardStatus.profileCreated,
        );
        
        final result = await _updateProfileUseCase(params);
        
        switch (result) {
          case Success<void>():
            emit(currentState.copyWith(
              firstName: event.firstName,
              lastName: event.lastName,
              email: event.email,
              reasonForUsingHushh: event.reasonForUsingHushh,
              currentStep: OnboardStatus.profileCreated,
            ));
          case Failed<void>():
            emit(ProfileCompletionErrorState(message: result.failure.message));
        }
      } catch (e) {
        emit(ProfileCompletionErrorState(message: e.toString()));
      }
    }
  }
  
  void _onSelectCategory(
    SelectCategoryEvent event,
    Emitter<ProfileCompletionState> emit,
  ) async {
    if (state is ProfileCompletionLoadedState) {
      final currentState = state as ProfileCompletionLoadedState;
      
      emit(ProfileCompletionUpdatingState());
      
      try {
        final params = UpdateAgentProfileParams(
          agentId: currentState.agentId,
          selectedCategoryId: event.categoryId,
          onboardStatus: OnboardStatus.categorySelected,
        );
        
        final result = await _updateProfileUseCase(params);
        
        switch (result) {
          case Success<void>():
            emit(currentState.copyWith(
              selectedCategoryId: event.categoryId,
              currentStep: OnboardStatus.categorySelected,
              brands: [], // Clear brands when category changes
            ));
            
            // Load brands for selected category
            add(LoadBrandsEvent(categoryId: event.categoryId));
          case Failed<void>():
            emit(ProfileCompletionErrorState(message: result.failure.message));
        }
      } catch (e) {
        emit(ProfileCompletionErrorState(message: e.toString()));
      }
    }
  }
  
  void _onSelectBrand(
    SelectBrandEvent event,
    Emitter<ProfileCompletionState> emit,
  ) async {
    if (state is ProfileCompletionLoadedState) {
      final currentState = state as ProfileCompletionLoadedState;
      
      emit(ProfileCompletionUpdatingState());
      
      try {
        final params = UpdateAgentProfileParams(
          agentId: currentState.agentId,
          selectedBrandId: event.brandId,
          onboardStatus: OnboardStatus.brandSelected,
        );
        
        final result = await _updateProfileUseCase(params);
        
        switch (result) {
          case Success<void>():
            emit(currentState.copyWith(
              selectedBrandId: event.brandId,
              currentStep: OnboardStatus.brandSelected,
            ));
          case Failed<void>():
            emit(ProfileCompletionErrorState(message: result.failure.message));
        }
      } catch (e) {
        emit(ProfileCompletionErrorState(message: e.toString()));
      }
    }
  }
  
  void _onCompleteProfile(
    CompleteProfileEvent event,
    Emitter<ProfileCompletionState> emit,
  ) async {
    if (state is ProfileCompletionLoadedState) {
      final currentState = state as ProfileCompletionLoadedState;
      
      emit(ProfileCompletionUpdatingState());
      
      try {
        final params = UpdateAgentProfileParams(
          agentId: currentState.agentId,
          onboardStatus: OnboardStatus.completed,
        );
        
        final result = await _updateProfileUseCase(params);
        
        switch (result) {
          case Success<void>():
            emit(ProfileCompletionCompletedState());
          case Failed<void>():
            emit(ProfileCompletionErrorState(message: result.failure.message));
        }
      } catch (e) {
        emit(ProfileCompletionErrorState(message: e.toString()));
      }
    }
  }
} 