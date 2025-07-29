import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/data/datasources/hushh_agent_firestore_service.dart';

// Events
abstract class ProfileCompletionEvent extends Equatable {
  const ProfileCompletionEvent();
  
  @override
  List<Object> get props => [];
}

class SubmitEmailEvent extends ProfileCompletionEvent {
  final String email;

  const SubmitEmailEvent(this.email);

  @override
  List<Object> get props => [email];
}

class CompleteProfileEvent extends ProfileCompletionEvent {
  final String email;
  final String name;

  const CompleteProfileEvent({
    required this.email,
    required this.name,
  });

  @override
  List<Object> get props => [email, name];
}

// States
abstract class ProfileCompletionState extends Equatable {
  const ProfileCompletionState();
  
  @override
  List<Object> get props => [];
}

class ProfileCompletionInitialState extends ProfileCompletionState {
  const ProfileCompletionInitialState();
}

class ProfileCompletionLoadingState extends ProfileCompletionState {
  const ProfileCompletionLoadingState();
}

class ProfileCompletionEmailSubmittedState extends ProfileCompletionState {
  final String email;

  const ProfileCompletionEmailSubmittedState(this.email);

  @override
  List<Object> get props => [email];
}

class ProfileCompletionCompletedState extends ProfileCompletionState {
  final String email;
  final String name;

  const ProfileCompletionCompletedState({
    required this.email,
    required this.name,
  });

  @override
  List<Object> get props => [email, name];
}

class ProfileCompletionErrorState extends ProfileCompletionState {
  final String message;

  const ProfileCompletionErrorState(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class ProfileCompletionBloc extends Bloc<ProfileCompletionEvent, ProfileCompletionState> {
  final HushhAgentFirestoreService _agentService = HushhAgentFirestoreService();

  ProfileCompletionBloc() : super(const ProfileCompletionInitialState()) {
    on<SubmitEmailEvent>(_onSubmitEmail);
    on<CompleteProfileEvent>(_onCompleteProfile);
  }

  void _onSubmitEmail(SubmitEmailEvent event, Emitter<ProfileCompletionState> emit) async {
    emit(const ProfileCompletionLoadingState());
    
    try {
      // Validate email format
      if (!_isValidEmail(event.email)) {
        emit(const ProfileCompletionErrorState('Please enter a valid email address'));
        return;
      }

      // For now, just proceed to name input
      // In a real app, you might want to check if email exists, etc.
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(ProfileCompletionEmailSubmittedState(event.email));
    } catch (e) {
      emit(ProfileCompletionErrorState('Failed to process email: ${e.toString()}'));
    }
  }

  void _onCompleteProfile(CompleteProfileEvent event, Emitter<ProfileCompletionState> emit) async {
    emit(const ProfileCompletionLoadingState());
    
    try {
      // Validate inputs
      if (!_isValidEmail(event.email)) {
        emit(const ProfileCompletionErrorState('Please enter a valid email address'));
        return;
      }
      
      if (!_isValidName(event.name)) {
        emit(const ProfileCompletionErrorState('Please enter a valid name (at least 2 characters)'));
        return;
      }

      // Create or update agent in Firestore
      await _agentService.createOrUpdateAgent(
        email: event.email,
        name: event.name,
        fullName: event.name, // Using name as fullName for now
      );

      print('✅ [ProfileCompletion] Profile completed successfully');
      emit(ProfileCompletionCompletedState(
        email: event.email,
        name: event.name,
      ));
    } catch (e) {
      print('❌ [ProfileCompletion] Error completing profile: $e');
      emit(ProfileCompletionErrorState('Failed to complete profile: ${e.toString()}'));
    }
  }

  bool _isValidEmail(String email) {
    return email.isNotEmpty && 
           email.contains('@') && 
           email.contains('.') &&
           RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool _isValidName(String name) {
    return name.isNotEmpty && name.trim().length >= 2;
  }
} 