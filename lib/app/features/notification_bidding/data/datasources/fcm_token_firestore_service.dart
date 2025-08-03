import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/fcm_token_model.dart';
import 'fcm_service.dart';

class FcmTokenFirestoreService {
  static const String _collectionName = 'Hushhagents';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FcmService _fcmService = FcmService();

  /// Get collection reference
  CollectionReference<Map<String, dynamic>> get _collection {
    return _firestore.collection(_collectionName);
  }

  /// Save FCM token to user document
  Future<void> saveFcmToken(String token, String platform) async {
    try {
      print('🔄 [FCM] Saving FCM token...');

      // Get current Firebase Auth user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      final uid = currentUser.uid;
      print('🔑 [FCM] Using Firebase Auth UID: $uid');

      // Initialize FCM if not already done
      await _fcmService.initialize();

      // Get current FCM token if not provided
      String fcmToken = token;
      if (token.isEmpty) {
        final currentToken = await _fcmService.getCurrentToken();
        if (currentToken != null) {
          fcmToken = currentToken;
        } else {
          throw Exception('Failed to get FCM token');
        }
      }

      // Create FCM token model
      final fcmTokenModel = FcmTokenModel.create(
        userId: uid,
        token: fcmToken,
        platform: platform,
      );

      // Update the user document with FCM token
      await _collection.doc(uid).update({
        'fcm_token': fcmToken,
        'platform': platform,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('✅ [FCM] FCM token saved successfully: $uid');
    } catch (e) {
      print('❌ [FCM] Error saving FCM token: $e');
      throw Exception('Failed to save FCM token: ${e.toString()}');
    }
  }

  /// Get FCM token for current user
  Future<FcmTokenModel?> getFcmToken() async {
    try {
      print('🔍 [FCM] Getting FCM token...');

      // Get current Firebase Auth user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      final uid = currentUser.uid;
      print('🔑 [FCM] Using Firebase Auth UID: $uid');

      // Get user document
      final doc = await _collection.doc(uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        if (data.containsKey('fcm_token')) {
          final fcmToken = FcmTokenModel.fromJson({
            ...data,
            'id': doc.id,
          });
          print('✅ [FCM] FCM token found: ${fcmToken.token}');
          return fcmToken;
        } else {
          print('ℹ️ [FCM] No FCM token found for user: $uid');
          return null;
        }
      } else {
        print('ℹ️ [FCM] User document not found: $uid');
        return null;
      }
    } catch (e) {
      print('❌ [FCM] Error getting FCM token: $e');
      throw Exception('Failed to get FCM token: ${e.toString()}');
    }
  }

  /// Update FCM token
  Future<void> updateFcmToken(String token) async {
    try {
      print('🔄 [FCM] Updating FCM token...');

      // Get current Firebase Auth user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      final uid = currentUser.uid;
      print('🔑 [FCM] Using Firebase Auth UID: $uid');

      // Update the FCM token
      await _collection.doc(uid).update({
        'fcm_token': token,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('✅ [FCM] FCM token updated successfully: $uid');
    } catch (e) {
      print('❌ [FCM] Error updating FCM token: $e');
      throw Exception('Failed to update FCM token: ${e.toString()}');
    }
  }

  /// Delete FCM token
  Future<void> deleteFcmToken() async {
    try {
      print('🔄 [FCM] Deleting FCM token...');

      // Get current Firebase Auth user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      final uid = currentUser.uid;
      print('🔑 [FCM] Using Firebase Auth UID: $uid');

      // Delete FCM token from Firebase
      await _fcmService.deleteToken();

      // Remove the FCM token field from Firestore
      await _collection.doc(uid).update({
        'fcm_token': FieldValue.delete(),
        'platform': FieldValue.delete(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      print('✅ [FCM] FCM token deleted successfully: $uid');
    } catch (e) {
      print('❌ [FCM] Error deleting FCM token: $e');
      throw Exception('Failed to delete FCM token: ${e.toString()}');
    }
  }
}
