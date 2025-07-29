import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
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
        throw Exception(
            'Phone number is too short. Please enter a valid phone number.');
      }

      print('📱 [AUTH] Starting phone OTP process for: $formattedPhone');

      // Additional safety check for Firebase initialization
      if (_auth.app == null) {
        throw Exception(
            'Firebase is not properly initialized. Please restart the app.');
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
          await _agentService.updateAgentLoginStatus(
              _currentAgent!.agentId, true);
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
      // Generate 6-digit OTP
      final otp = (100000 + Random().nextInt(900000)).toString();
      
      // Store OTP in Firestore for verification
      await FirebaseFirestore.instance
          .collection('email_otps')
          .doc(email)
          .set({
        'email': email,
        'otp': otp,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(const Duration(minutes: 10)).millisecondsSinceEpoch,
        'isUsed': false,
        'method': 'email_otp',
      });

      // Display OTP in console for development
      print('');
      print('🎯 [EMAIL_OTP] ════════════════════════════════════════════════════════════');
      print('🎯 [EMAIL_OTP]                    VERIFICATION CODE                         ');  
      print('🎯 [EMAIL_OTP] ════════════════════════════════════════════════════════════');
      print('🎯 [EMAIL_OTP]   📧 Email: $email');
      print('🎯 [EMAIL_OTP]   📱 YOUR OTP CODE: $otp');
      print('🎯 [EMAIL_OTP]   ⏰ Valid for: 10 minutes');
      print('🎯 [EMAIL_OTP] ════════════════════════════════════════════════════════════');
      print('🎯 [EMAIL_OTP]   👆 COPY THIS CODE AND ENTER IN YOUR APP 👆');
      print('🎯 [EMAIL_OTP] ════════════════════════════════════════════════════════════');
      print('');
      print('✅ [AUTH] ★ OTP ready for immediate verification ★');
      print('📧 [AUTH] Email OTP generated successfully!');
      print('');

      // TODO: Add your working email API implementation here
      // Example:
      // await _sendEmailViaResend(email, otp);
      // await _sendEmailViaEmailJS(email, otp);
      // await _sendEmailViaMailgun(email, otp);
      
      // For development, console OTP is reliable and always works
      print('📱 [INFO] Use the OTP code displayed above for verification');
      print('📧 [INFO] Integrate your working email API above to send real emails');

    } catch (e) {
      // Handle specific Firebase error codes
      String errorMessage;
      if (e is firebase_auth.FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'Invalid email address format.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many requests. Please wait before trying again.';
            break;
          case 'network-request-failed':
            errorMessage = 'Network error. Please check your internet connection.';
            break;
          default:
            errorMessage = 'Failed to send email OTP: ${e.message}';
        }
      } else {
        errorMessage = 'Failed to send email OTP: $e';
      }
      throw Exception(errorMessage);
    }
  }

  @override
  Future<firebase_auth.UserCredential> verifyEmailOtp(String email, String otp) async {
    try {
      // Get OTP from Firestore
      final otpDoc = await FirebaseFirestore.instance
          .collection('email_otps')
          .doc(email)
          .get();

      if (!otpDoc.exists) {
        throw Exception('No OTP found for this email. Please request a new OTP.');
      }

      final otpData = otpDoc.data()!;
      final storedOtp = otpData['otp'] as String;
      final expiresAt = otpData['expiresAt'] as int;
      final isUsed = otpData['isUsed'] as bool;

      // Check if OTP is expired
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        throw Exception('OTP has expired. Please request a new OTP.');
      }

      // Check if OTP is already used
      if (isUsed) {
        throw Exception('OTP has already been used. Please request a new OTP.');
      }

      // Verify OTP
      if (storedOtp != otp) {
        throw Exception('Invalid OTP. Please check and try again.');
      }

      // Mark OTP as used
      await FirebaseFirestore.instance
          .collection('email_otps')
          .doc(email)
          .update({'isUsed': true});

      // Create user credential after successful OTP verification
      firebase_auth.UserCredential userCredential;
      
      // Check if user already exists
      final signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      
      if (signInMethods.isNotEmpty) {
        // User exists - sign in anonymously and update profile
        userCredential = await _auth.signInAnonymously();
        await userCredential.user!.updateEmail(email);
      } else {
        // New user - create anonymous account and link email
        userCredential = await _auth.signInAnonymously();
        await userCredential.user!.updateEmail(email);
      }

      print('✅ [EMAIL_AUTH] User authenticated successfully via email OTP');
      print('👤 [EMAIL_AUTH] User ID: ${userCredential.user?.uid}');
      print('📧 [EMAIL_AUTH] Email: $email');

      return userCredential;
    } catch (e) {
      throw Exception('Failed to verify email OTP: $e');
    }
  }


  /// UNUSED: Send email OTP via working Webhook.site - guaranteed to work
  
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
  Future<firebase_auth.UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      throw Exception('Failed to sign in with email: $e');
    }
  }

  @override
  Future<firebase_auth.UserCredential> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      throw Exception('Failed to sign up with email: $e');
    }
  }

  @override
  Future<void> signInWithPhoneNumber(String phoneNumber) async {
    await sendPhoneOtp(phoneNumber);
  }

  @override
  Future<firebase_auth.UserCredential> verifyOTP(
      String verificationId, String otp) async {
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
      final doc = await _firestore.collection('agents').doc(agentId).get();

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
      final cardData = agentCard.toJson()
        ..['updatedAt'] = now.toIso8601String();

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
      final doc = await _firestore.collection('agents').doc(agentId).get();

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

      await _firestore.collection('users').doc(userId).set(data);
    } catch (e) {
      throw Exception('Failed to create user data: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

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

      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }
}
