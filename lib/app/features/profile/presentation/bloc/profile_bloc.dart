import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetProfileEvent extends ProfileEvent {
  const GetProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final String? displayName;
  final String? email;
  final String? avatarUrl;

  const UpdateProfileEvent({this.displayName, this.email, this.avatarUrl});

  @override
  List<Object?> get props => [displayName, email, avatarUrl];
}

class UploadProfileImageEvent extends ProfileEvent {
  final String imagePath;

  const UploadProfileImageEvent(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String displayName;
  final String email;
  final String phoneNumber;
  final String? avatarUrl;

  const ProfileLoaded({
    required this.displayName,
    required this.email,
    required this.phoneNumber,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [displayName, email, phoneNumber, avatarUrl];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdating extends ProfileState {
  final String displayName;
  final String email;
  final String phoneNumber;
  final String? avatarUrl;

  const ProfileUpdating({
    required this.displayName,
    required this.email,
    required this.phoneNumber,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [displayName, email, phoneNumber, avatarUrl];
}

class ProfileUpdated extends ProfileState {
  final String displayName;
  final String email;
  final String phoneNumber;
  final String? avatarUrl;

  const ProfileUpdated({
    required this.displayName,
    required this.email,
    required this.phoneNumber,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [displayName, email, phoneNumber, avatarUrl];
}

class ImageUploading extends ProfileState {
  final String displayName;
  final String email;
  final String phoneNumber;
  final String? avatarUrl;

  const ImageUploading({
    required this.displayName,
    required this.email,
    required this.phoneNumber,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [displayName, email, phoneNumber, avatarUrl];
}

class ImageUploaded extends ProfileState {
  final String imageUrl;
  final String displayName;
  final String email;
  final String phoneNumber;

  const ImageUploaded({
    required this.imageUrl,
    required this.displayName,
    required this.email,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [imageUrl, displayName, email, phoneNumber];
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UploadProfileImageEvent>(_onUploadProfileImage);
  }

  Future<void> _onGetProfile(
    GetProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(const ProfileError('User not authenticated'));
        return;
      }

      // Fetch profile data from Hushhagents collection
      final doc = await FirebaseFirestore.instance
          .collection('Hushhagents')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        // Try to get phone from Firebase Auth user
        final phoneNumber = user.phoneNumber ?? 'Add phone number';
        emit(ProfileLoaded(
          displayName: 'Update your name',
          email: 'Add email',
          phoneNumber: phoneNumber,
        ));
        return;
      }

      final data = doc.data()!;
      final displayName = data['name'] ?? 'Update your name';
      final email = data['email'] ?? 'Add email';
      final phoneNumber =
          data['phone'] ?? user.phoneNumber ?? 'Add phone number';
      final avatarUrl = data['profilePictureUrl'] as String?;

      print(
          '✅ [Profile] Loaded profile data: name=$displayName, email=$email, phone=$phoneNumber');

      emit(ProfileLoaded(
        displayName: displayName,
        email: email,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
      ));
    } catch (e) {
      print('❌ [Profile] Error loading profile: $e');
      emit(ProfileError('Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdating(
      displayName: event.displayName ?? 'Update your name',
      email: event.email ?? 'Add email',
      phoneNumber: 'Add phone number', // Will be updated from current state
      avatarUrl: event.avatarUrl,
    ));

    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(const ProfileError('User not authenticated'));
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

      emit(ProfileUpdated(
        displayName: event.displayName ?? 'Update your name',
        email: event.email ?? 'Add email',
        phoneNumber: 'Add phone number', // Will be updated from current state
        avatarUrl: event.avatarUrl,
      ));
    } catch (e) {
      print('❌ [Profile] Error updating profile: $e');
      emit(ProfileError('Failed to update profile: ${e.toString()}'));
    }
  }

  Future<void> _onUploadProfileImage(
    UploadProfileImageEvent event,
    Emitter<ProfileState> emit,
  ) async {
    // For now, just emit success without actual upload
    // TODO: Implement actual image upload to Firebase Storage
    emit(const ImageUploaded(
      imageUrl: 'https://example.com/placeholder.jpg',
      displayName: 'Update your name',
      email: 'Add email',
      phoneNumber: 'Add phone number',
    ));
  }
}
