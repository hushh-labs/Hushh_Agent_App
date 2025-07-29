import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  
  @override
  List<Object> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final String? displayName;
  final String? email;
  final String? avatarUrl;

  const UpdateProfileEvent({
    this.displayName,
    this.email,
    this.avatarUrl,
  });

  @override
  List<Object> get props => [displayName ?? '', email ?? '', avatarUrl ?? ''];
}

class SendFeedbackEvent extends ProfileEvent {
  final String feedback;

  const SendFeedbackEvent(this.feedback);

  @override
  List<Object> get props => [feedback];
}

class DeleteAccountEvent extends ProfileEvent {
  const DeleteAccountEvent();
}

class SignOutEvent extends ProfileEvent {
  const SignOutEvent();
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();
  
  @override
  List<Object> get props => [];
}

class ProfileInitialState extends ProfileState {
  const ProfileInitialState();
}

class ProfileLoadingState extends ProfileState {
  const ProfileLoadingState();
}

class ProfileLoadedState extends ProfileState {
  final String displayName;
  final String email;
  final String? avatarUrl;

  const ProfileLoadedState({
    required this.displayName,
    required this.email,
    this.avatarUrl,
  });

  @override
  List<Object> get props => [displayName, email, avatarUrl ?? ''];
}

class ProfileUpdatingState extends ProfileState {
  const ProfileUpdatingState();
}

class ProfileUpdatedState extends ProfileState {
  final String message;

  const ProfileUpdatedState(this.message);

  @override
  List<Object> get props => [message];
}

class ProfileErrorState extends ProfileState {
  final String message;

  const ProfileErrorState(this.message);

  @override
  List<Object> get props => [message];
}

class FeedbackSentState extends ProfileState {
  const FeedbackSentState();
}

class AccountDeletedState extends ProfileState {
  const AccountDeletedState();
}

class SignedOutState extends ProfileState {
  const SignedOutState();
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileInitialState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<SendFeedbackEvent>(_onSendFeedback);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<SignOutEvent>(_onSignOut);
  }

  void _onLoadProfile(LoadProfileEvent event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoadingState());
    
    try {
      // TODO: Implement actual profile loading from repository
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock data for now
      emit(const ProfileLoadedState(
        displayName: 'Update your name',
        email: 'Add email',
      ));
    } catch (e) {
      emit(ProfileErrorState('Failed to load profile: ${e.toString()}'));
    }
  }

  void _onUpdateProfile(UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(const ProfileUpdatingState());
    
    try {
      // TODO: Implement actual profile update logic
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(const ProfileUpdatedState('Profile updated successfully'));
    } catch (e) {
      emit(ProfileErrorState('Failed to update profile: ${e.toString()}'));
    }
  }

  void _onSendFeedback(SendFeedbackEvent event, Emitter<ProfileState> emit) async {
    try {
      // TODO: Implement actual feedback sending logic
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(const FeedbackSentState());
    } catch (e) {
      emit(ProfileErrorState('Failed to send feedback: ${e.toString()}'));
    }
  }

  void _onDeleteAccount(DeleteAccountEvent event, Emitter<ProfileState> emit) async {
    try {
      // TODO: Implement actual account deletion logic
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(const AccountDeletedState());
    } catch (e) {
      emit(ProfileErrorState('Failed to delete account: ${e.toString()}'));
    }
  }

  void _onSignOut(SignOutEvent event, Emitter<ProfileState> emit) async {
    try {
      // TODO: Implement actual sign out logic
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(const SignedOutState());
    } catch (e) {
      emit(ProfileErrorState('Failed to sign out: ${e.toString()}'));
    }
  }
} 