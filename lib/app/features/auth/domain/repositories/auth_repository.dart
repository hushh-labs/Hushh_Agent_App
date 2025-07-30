import 'package:firebase_auth/firebase_auth.dart';
import '../entities/agent_card.dart';

/// Abstract repository interface for authentication operations
abstract class AuthRepository {
  /// Sign out the current user
  Future<void> signOut();

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password);

  /// Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password);

  /// Send phone OTP
  Future<void> sendPhoneOtp(String phoneNumber,
      {Function(String phoneNumber)? onOtpSent});

  /// Sign in with phone number
  Future<void> signInWithPhoneNumber(String phoneNumber);

  /// Verify phone OTP using stored verification ID
  Future<UserCredential> verifyPhoneOtp(String phoneNumber, String otp);

  /// Verify OTP for phone authentication with explicit verification ID
  Future<UserCredential> verifyOTP(String verificationId, String otp);

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle();

  /// Sign in with Apple
  Future<UserCredential> signInWithApple();

  /// Get current user
  User? getCurrentUser();

  /// Check if user is authenticated
  bool isAuthenticated();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Send email OTP
  Future<void> sendEmailOtp(String email);

  /// Verify email OTP
  Future<UserCredential> verifyEmailOtp(String email, String otp);

  /// Resend OTP
  Future<void> resendOTP(String phoneNumber);

  /// Delete user account
  Future<void> deleteAccount();

  /// Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL});

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;

  // Agent Card Operations
  /// Get agent card by agent ID
  Future<AgentCard?> getAgentCard(String agentId);

  /// Create agent card
  Future<void> createAgentCard(AgentCard agentCard);

  /// Update agent card
  Future<void> updateAgentCard(AgentCard agentCard);

  /// Check if agent card exists
  Future<bool> doesAgentCardExist(String agentId);

  /// Check if user has complete profile (name, email, brands, categories)
  Future<bool> doesUserHaveCompleteProfile(String agentId);
}
