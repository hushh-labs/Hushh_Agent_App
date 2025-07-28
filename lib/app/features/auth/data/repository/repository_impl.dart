import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/agent_card.dart';
import '../models/agent_card_model.dart';
import '../datasources/hushh_agent_firestore_service.dart';
import '../models/hushh_agent_model.dart';



class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final HushhAgentFirestoreService _agentService = HushhAgentFirestoreService();

  // Store verification ID for OTP verification
  String? _verificationId;
  // Store verification email for email OTP verification
  String? _verificationEmail;
  // Store current agent data
  HushhAgentModel? _currentAgent;

  @override
  Future<void> sendPhoneOtp(
    String phoneNumber, {
    Function(String phoneNumber)? onOtpSent,
  }) async {
    try {
      // Ensure phone number has proper format for Firebase
      String formattedPhone = phoneNumber.trim();
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+$formattedPhone';
      }

      // Validate phone number format
      if (formattedPhone.length < 10) {
        throw Exception('Phone number is too short. Please enter a valid phone number.');
      }

      print('📱 [AUTH] Starting phone OTP process for: $formattedPhone');
      
      // Additional safety check for Firebase initialization
      if (_auth.app == null) {
        throw Exception('Firebase is not properly initialized. Please restart the app.');
      }

      // Create or update agent record in Firestore
      try {
        _currentAgent = await _agentService.createOrUpdateAgent(
          phone: formattedPhone,
        );
        print('✅ [AUTH] Agent record created/updated in Firestore');
      } catch (e) {
        print('❌ [AUTH] Failed to create agent record: $e');
        // Continue with OTP process even if Firestore fails
      }

      // Use a Completer to handle the async callback properly
      final completer = Completer<void>();

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted:
            (firebase_auth.PhoneAuthCredential credential) async {
              // Completely disable auto-verification to force manual OTP entry
              // Do nothing - let user manually enter OTP
              print('📱 [AUTH] Auto-verification completed (ignoring)');
            },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          // Handle specific Firebase error codes
          String errorMessage;
          switch (e.code) {
            case 'too-many-requests':
              errorMessage =
                  'Too many OTP requests. Please wait a few minutes before trying again.';
              break;
            case 'invalid-phone-number':
              errorMessage =
                  'Invalid phone number format. Please check and try again.';
              break;
            case 'quota-exceeded':
              errorMessage = 'SMS quota exceeded. Please try again later.';
              break;
            case 'network-request-failed':
              errorMessage =
                  'Network error. Please check your internet connection and try again.';
              break;
            default:
              errorMessage = 'Failed to send OTP: ${e.message}';
          }

          // Complete with error
          if (!completer.isCompleted) {
            completer.completeError(Exception(errorMessage));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          // Store verification ID for later use
          _verificationId = verificationId;

          // Complete successfully
          if (!completer.isCompleted) {
            completer.complete();
          }

          // Call navigation callback if provided
          if (onOtpSent != null) {
            onOtpSent(phoneNumber);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // OTP auto-retrieval timeout
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        timeout: const Duration(seconds: 60),
      );

      // Wait for the completer to complete
      await completer.future;
    } catch (e) {
      // Re-throw the exception with the specific error message
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Failed to send OTP: $e');
      }
    }
  }

  @override
  Future<firebase_auth.UserCredential> verifyPhoneOtp(
    String phoneNumber,
    String otp,
  ) async {
    try {
      if (_verificationId == null) {
        throw Exception('No verification ID found. Please send OTP first.');
      }

      // Create credential with verification ID and OTP
      firebase_auth.PhoneAuthCredential credential =
          firebase_auth.PhoneAuthProvider.credential(
            verificationId: _verificationId!,
            smsCode: otp,
          );

      // Sign in with credential
      final userCredential = await _auth.signInWithCredential(credential);

      print('✅ [AUTH] Phone OTP verified successfully');

      // Update agent login status in Firestore
      if (_currentAgent != null) {
        try {
          await _agentService.updateAgentLoginStatus(_currentAgent!.agentId, true);
          print('✅ [AUTH] Agent login status updated in Firestore');
        } catch (e) {
          print('❌ [AUTH] Failed to update agent login status: $e');
          // Continue anyway, authentication was successful
        }
      }

      // Clear verification ID after successful verification
      _verificationId = null;

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendEmailOtp(String email) async {
    try {
      print('📧 [AUTH] Starting email OTP process for: $email');

      // Create or update agent record in Firestore with email
      try {
        _currentAgent = await _agentService.createOrUpdateAgent(
          email: email,
        );
        print('✅ [AUTH] Agent record created/updated with email in Firestore');
      } catch (e) {
        print('❌ [AUTH] Failed to create agent record: $e');
        // Continue with OTP process even if Firestore fails
      }

      // For demonstration, we'll simulate sending an email OTP
      // In a real implementation, you would integrate with an email service
      // like SendGrid, Firebase Functions, or your backend API
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Store the email for verification (in real app, this would be handled by your backend)
      _verificationEmail = email;
      
      // In a real implementation, you would:
      // 1. Generate a random OTP
      // 2. Send it via email service
      // 3. Store it securely for verification
      
      print('🚀 [DEMO] Email OTP sent to: $email');
    } catch (e) {
      throw Exception('Failed to send email OTP: $e');
    }
  }

  @override
  Future<firebase_auth.UserCredential> verifyEmailOtp(
    String email,
    String otp,
  ) async {
    try {
      if (_verificationEmail == null || _verificationEmail != email) {
        throw Exception('No verification found for this email. Please send OTP first.');
      }

      // For demonstration, we'll accept any 6-digit OTP
      // In a real implementation, you would verify the OTP with your backend
      if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
        throw Exception('Invalid OTP format. Please enter a 6-digit code.');
      }

      // For demo purposes, accept OTP "123456" or any 6-digit number
      // In production, verify with your backend service
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Clear verification email after successful verification
      _verificationEmail = null;

      // For email authentication, you might create a custom token or use Firebase Auth
      // For now, we'll simulate successful authentication
      // In a real app, you would integrate with your authentication system
      
      print('✅ [AUTH] Email OTP verified successfully for: $email');

      // Update agent login status in Firestore
      if (_currentAgent != null) {
        try {
          await _agentService.updateAgentLoginStatus(_currentAgent!.agentId, true);
          print('✅ [AUTH] Agent login status updated in Firestore');
        } catch (e) {
          print('❌ [AUTH] Failed to update agent login status: $e');
          // Continue anyway, authentication was successful
        }
      }
      
      // Create anonymous user for demonstration
      // In production, you would handle this based on your authentication flow
      final userCredential = await _auth.signInAnonymously();
      
      return userCredential;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Failed to verify email OTP: $e');
      }
    }
  }

  @override
  firebase_auth.User? getCurrentUser() {
    return _auth.currentUser;
  }

  @override
  bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Future<firebase_auth.UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Failed to sign in with email: $e');
    }
  }

  @override
  Future<firebase_auth.UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Failed to sign up with email: $e');
    }
  }

  @override
  Future<void> signInWithPhoneNumber(String phoneNumber) async {
    await sendPhoneOtp(phoneNumber);
  }

  @override
  Future<firebase_auth.UserCredential> verifyOTP(String verificationId, String otp) async {
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  @override
  Future<firebase_auth.UserCredential> signInWithGoogle() async {
    throw UnimplementedError('Google sign in not implemented yet');
  }

  @override
  Future<firebase_auth.UserCredential> signInWithApple() async {
    throw UnimplementedError('Apple sign in not implemented yet');
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  @override
  Future<void> resendOTP(String phoneNumber) async {
    await sendPhoneOtp(phoneNumber);
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<AgentCard?> getAgentCard(String agentId) async {
    try {
      final doc = await _firestore
          .collection('agents')
          .doc(agentId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return AgentCardModel.fromJson({'id': doc.id, ...data});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get agent card: $e');
    }
  }

  @override
  Future<void> createAgentCard(AgentCard agentCard) async {
    try {
      final now = DateTime.now();
      final cardData = agentCard.toJson()
        ..['createdAt'] = now.toIso8601String()
        ..['updatedAt'] = now.toIso8601String();

      await _firestore
          .collection('agents')
          .doc(agentCard.agentId)
          .set(cardData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create agent card: $e');
    }
  }

  @override
  Future<void> updateAgentCard(AgentCard agentCard) async {
    try {
      final now = DateTime.now();
      final cardData = agentCard.toJson()..['updatedAt'] = now.toIso8601String();

      await _firestore
          .collection('agents')
          .doc(agentCard.agentId)
          .update(cardData);
    } catch (e) {
      throw Exception('Failed to update agent card: $e');
    }
  }

  @override
  Future<bool> doesAgentCardExist(String agentId) async {
    try {
      final doc = await _firestore
          .collection('agents')
          .doc(agentId)
          .get();

      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check agent card existence: $e');
    }
  }

  @override
  Future<void> createUserData(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final now = DateTime.now();
      final data = {
        ...userData,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .set(data);
    } catch (e) {
      throw Exception('Failed to create user data: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  @override
  Future<void> updateUserData(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final now = DateTime.now();
      final data = {...userData, 'updatedAt': now.toIso8601String()};

      await _firestore
          .collection('users')
          .doc(userId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }
}