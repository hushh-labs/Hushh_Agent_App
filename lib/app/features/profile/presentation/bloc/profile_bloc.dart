import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(const ProfileErrorState('User not authenticated'));
        return;
      }

      // Fetch profile data from Hushhagents collection
      final doc = await FirebaseFirestore.instance
          .collection('Hushhagents')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        emit(const ProfileLoadedState(
          displayName: 'Update your name',
          email: 'Add email',
        ));
        return;
      }

      final data = doc.data()!;
      final displayName = data['name'] ?? 'Update your name';
      final email = data['email'] ?? 'Add email';
      final avatarUrl = data['profilePictureUrl'] as String?;

      print('✅ [Profile] Loaded profile data: name=$displayName, email=$email');

      emit(ProfileLoadedState(
        displayName: displayName,
        email: email,
        avatarUrl: avatarUrl,
      ));
    } catch (e) {
      print('❌ [Profile] Error loading profile: $e');
      emit(ProfileErrorState('Failed to load profile: ${e.toString()}'));
    }
  }

  void _onUpdateProfile(UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(const ProfileUpdatingState());
    
    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(const ProfileErrorState('User not authenticated'));
        return;
      }

      // Update profile data in Hushhagents collection
      final updateData = <String, dynamic>{};
      
      if (event.displayName != null) {
        updateData['name'] = event.displayName;
        updateData['fullName'] = event.displayName;
      }
      
      if (event.email != null) {
        updateData['email'] = event.email;
      }
      
      if (event.avatarUrl != null) {
        updateData['profilePictureUrl'] = event.avatarUrl;
      }
      
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance
          .collection('Hushhagents')
          .doc(user.uid)
          .update(updateData);

      print('✅ [Profile] Updated profile data: $updateData');

      emit(const ProfileUpdatedState('Profile updated successfully'));
    } catch (e) {
      print('❌ [Profile] Error updating profile: $e');
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