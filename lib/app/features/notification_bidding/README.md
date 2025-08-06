# Notification Bidding Feature

This feature implements FCM (Firebase Cloud Messaging) token management for both iOS and Android platforms, following clean architecture principles with BLoC pattern.

## Architecture

The feature follows clean architecture with the following layers:

### Domain Layer
- **Entities**: `FcmToken` - Core business object
- **Repositories**: `NotificationBiddingRepository` - Abstract interface
- **Use Cases**: 
  - `SaveFcmTokenUseCase` - Save FCM token
  - `GetFcmTokenUseCase` - Retrieve FCM token
  - `UpdateFcmTokenUseCase` - Update FCM token
  - `DeleteFcmTokenUseCase` - Delete FCM token

### Data Layer
- **Models**: `FcmTokenModel` - Data model extending entity
- **Datasources**: 
  - `FcmTokenFirestoreService` - Firestore operations
  - `FcmService` - Firebase Messaging operations
- **Repository**: `NotificationBiddingRepositoryImpl` - Implementation

### Presentation Layer
- **BLoC**: `NotificationBiddingBloc` - State management
- **Pages**: `NotificationBiddingPage` - UI demonstration
- **Components**: (To be added as needed)

## Features

### FCM Token Management
- **Save FCM Token**: Stores token in Firestore under user document
- **Get FCM Token**: Retrieves current FCM token
- **Update FCM Token**: Updates existing FCM token
- **Delete FCM Token**: Removes FCM token from both Firebase and Firestore

### Automatic FCM Token Management
- **✅ Automatic on Login**: FCM token is automatically saved when user successfully logs in
- **✅ Automatic on Logout**: FCM token is automatically deleted when user logs out
- **✅ Automatic on App Open**: FCM token is refreshed every time the app opens and user is logged in
- **✅ New Users**: FCM token saved for new users during registration
- **✅ Existing Users**: FCM token saved for existing users after profile completeness check
- **✅ Platform Detection**: Automatically detects iOS/Android/Web platform
- **✅ Error Handling**: Login/logout/app open process continues even if FCM token operations fail

### Platform Support
- **iOS**: Automatic permission request and token generation
- **Android**: Automatic token generation
- **Web**: Basic token support

### Firestore Integration
- Stores FCM token in `Hushhagents` collection
- Uses user's UID as document ID
- Field name: `fcm_token`
- Additional fields: `platform`, `updatedAt`

## Usage

### Automatic Integration
The FCM token is automatically saved upon successful login. No additional setup required.

**Login Flow:**
1. User enters phone/email and OTP
2. OTP verification succeeds
3. Profile completeness check runs
4. **FCM token is automatically saved** ✅
5. User proceeds to main app

**Logout Flow:**
1. User triggers logout
2. **FCM token is automatically deleted** ✅
3. User is signed out
4. User redirected to login screen

**App Open Flow:**
1. App opens and user is authenticated
2. Home sections load
3. **FCM token is automatically refreshed** ✅
4. User sees main app interface

### Manual Usage
```dart
// Initialize the feature
notification_di.initializeNotificationBiddingFeature();

// Navigate to the page
Navigator.pushNamed(context, AppRoutes.notificationBidding);
```

### Using the BLoC
```dart
// Initialize FCM token
bloc.add(InitializeFcmTokenEvent('ios'));

// Save FCM token
bloc.add(SaveFcmTokenEvent(token: 'your_token', platform: 'ios'));

// Get FCM token
bloc.add(GetFcmTokenEvent());

// Update FCM token
bloc.add(UpdateFcmTokenEvent('new_token'));

// Delete FCM token
bloc.add(DeleteFcmTokenEvent());
```

### Direct Service Usage
```dart
final fcmService = FcmService();

// Initialize FCM
await fcmService.initialize();

// Get current token
final token = await fcmService.getCurrentToken();

// Delete token
await fcmService.deleteToken();
```

## Dependencies

- `firebase_messaging` - For FCM operations
- `cloud_firestore` - For Firestore operations
- `firebase_auth` - For user authentication
- `flutter_bloc` - For state management
- `get_it` - For dependency injection

## File Structure

```
lib/app/features/notification_bidding/
├── data/
│   ├── datasources/
│   │   ├── fcm_service.dart
│   │   └── fcm_token_firestore_service.dart
│   ├── models/
│   │   └── fcm_token_model.dart
│   └── repository/
│       └── repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── fcm_token.dart
│   ├── repositories/
│   │   └── notification_bidding_repository.dart
│   └── usecases/
│       ├── save_fcm_token_usecase.dart
│       ├── get_fcm_token_usecase.dart
│       ├── update_fcm_token_usecase.dart
│       └── delete_fcm_token_usecase.dart
├── presentation/
│   ├── bloc/
│   │   └── notification_bidding_bloc.dart
│   └── pages/
│       └── notification_bidding_page.dart
├── di/
│   └── notification_bidding_injection.dart
└── README.md
```

## Integration with Auth

The FCM token saving is integrated into the authentication flow:

### Auth Use Case
- `SaveFcmTokenAfterLoginUseCase` - Automatically saves FCM token after successful login

### Integration Points
1. **New User Registration**: FCM token saved after OTP verification
2. **Existing User Login**: FCM token saved after profile completeness check
3. **User Logout**: FCM token deleted before sign out
4. **App Open**: FCM token refreshed when home loads (authenticated users only)
5. **Error Handling**: Login/logout/app open continues even if FCM token operations fail

### Logging
All FCM token operations are logged with appropriate prefixes:
- `✅ [AUTH] FCM token saved successfully after login`
- `⚠️ [AUTH] Failed to save FCM token after login`
- `✅ [AUTH] FCM token deleted during sign out`
- `⚠️ [AUTH] Failed to delete FCM token during sign out`
- `✅ [HOME] FCM token refreshed on app open`
- `⚠️ [HOME] Failed to refresh FCM token on app open`

## Future Enhancements

1. **Topic Subscription**: Add support for subscribing to specific topics
2. **Notification Handling**: Implement custom notification display
3. **Background Messages**: Handle background message processing
4. **Analytics**: Track notification engagement
5. **Settings**: Allow users to configure notification preferences

## Testing

The feature includes comprehensive error handling and logging for debugging purposes. All operations are logged with appropriate prefixes for easy identification. 