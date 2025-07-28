import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agent_profile_model.dart';
import '../../domain/entities/agent_profile.dart';
import '../../../../../shared/core/firebase/firestore_service.dart';

/// Abstract interface for splash remote data source
abstract class SplashRemoteDataSource {
  Future<bool> initializeFirebaseServices();
  Future<bool> isAgentAuthenticated();
  Future<AgentProfileModel?> getCurrentAgentProfile();
  Future<void> updateFCMToken(String agentId, String token);
  Future<bool> checkBusinessVerificationStatus(String agentId);
}

/// Implementation of splash remote data source using Firebase
class SplashRemoteDataSourceImpl implements SplashRemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Future<bool> initializeFirebaseServices() async {
    try {
      // Initialize Firestore
      await FirestoreService.initialize();
      
      // Check Firebase Auth state
      await _auth.authStateChanges().first;
      
      print('✅ [Remote] Firebase services initialized');
      return true;
    } catch (e) {
      print('❌ [Remote] Failed to initialize Firebase services: $e');
      return false;
    }
  }

  @override
  Future<bool> isAgentAuthenticated() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('🔐 [Remote] No authenticated user found');
        return false;
      }
      
      // Check if user email is verified
      if (!user.emailVerified) {
        print('⚠️ [Remote] User email not verified');
        return false;
      }
      
      print('✅ [Remote] Agent is authenticated: ${user.email}');
      return true;
    } catch (e) {
      print('❌ [Remote] Error checking authentication: $e');
      return false;
    }
  }

  @override
  Future<AgentProfileModel?> getCurrentAgentProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ [Remote] No authenticated user to get profile');
        return null;
      }

      // Get agent profile from Firestore
      final doc = await FirestoreService.getAgentProfile(user.uid);
      
      if (!doc.exists) {
        print('⚠️ [Remote] Agent profile not found, creating basic profile');
      
        // Create basic profile from Firebase Auth data
        final basicProfile = AgentProfileModel(
          agentId: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Agent',
          profilePictureUrl: user.photoURL,
          phoneNumber: user.phoneNumber,
        verificationStatus: AgentVerificationStatus.pending,
        isActive: true,
        isOnline: false,
        createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        hasCompletedOnboarding: false,
        hasCompletedBusinessSetup: false,
      );
        
        // Save to Firestore
        await FirestoreService.setAgentProfile(user.uid, basicProfile.toFirestore());
        
        return basicProfile;
      }
      
      // Convert Firestore document to model
      final data = doc.data() as Map<String, dynamic>;
      final profile = AgentProfileModel.fromFirestore(data, doc.id);
      
      print('✅ [Remote] Agent profile loaded: ${profile.displayName}');
      return profile;
      
    } catch (e) {
      print('❌ [Remote] Error getting agent profile: $e');
      return null;
    }
  }

  @override
  Future<void> updateFCMToken(String agentId, String token) async {
    try {
      await _firestore.collection('agents').doc(agentId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ [Remote] FCM token updated for agent: $agentId');
    } catch (e) {
      print('❌ [Remote] Error updating FCM token: $e');
      rethrow;
    }
  }

  @override
  Future<bool> checkBusinessVerificationStatus(String agentId) async {
    try {
      final businessDoc = await FirestoreService.getBusinessProfile(agentId);
      
      if (!businessDoc.exists) {
        print('⚠️ [Remote] Business data not found for agent: $agentId');
        return false;
      }
      
      final data = businessDoc.data() as Map<String, dynamic>;
      final isVerified = data['isVerified'] as bool? ?? false;
      
      print('✅ [Remote] Business verification status: $isVerified');
      return isVerified;
      
    } catch (e) {
      print('❌ [Remote] Error checking business verification: $e');
      return false;
    }
  }
} 