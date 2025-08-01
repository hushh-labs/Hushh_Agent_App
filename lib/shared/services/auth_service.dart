import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/app_routes.dart';

/// Direct authentication service for logout and account management
/// This service doesn't require BLoC providers and can be called directly
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  /// Direct logout functionality
  static Future<bool> logout(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Sign out from Firebase
      await _auth.signOut();

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Navigate to auth page and clear all previous routes
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.mainAuth,
          (route) => false,
        );
      }

      return true;
    } catch (e) {
      print('❌ Logout error: $e');

      // Close loading dialog if it's showing
      if (context.mounted) {
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to logout: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      return false;
    }
  }

  /// Direct delete account functionality
  static Future<bool> deleteAccount(BuildContext context) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently signed in');
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Deleting account...'),
            ],
          ),
        ),
      );

      final userId = currentUser.uid;

      // Delete user data from Firestore collections
      await _deleteUserData(userId);

      // Delete the Firebase Auth account
      await currentUser.delete();

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Navigate to auth page and clear all previous routes
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.mainAuth,
          (route) => false,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      return true;
    } catch (e) {
      print('❌ Delete account error: $e');

      // Close loading dialog if it's showing
      if (context.mounted) {
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      return false;
    }
  }

  /// Delete all user data from Firestore
  static Future<void> _deleteUserData(String userId) async {
    final batch = _firestore.batch();

    try {
      print('🗑️ Starting deletion of user data for: $userId');

      // STEP 1: Delete from Hushhagents collection and its subcollections
      await _deleteHushhAgentsData(userId, batch);

      // STEP 2: List of other collections to clean
      final collectionsToClean = [
        'HushhAgents',
        'users',
        'lookbooks',
        'products', // Old flat structure (for backward compatibility)
        'notifications',
        'chats',
        'feedback',
      ];

      // Delete documents where the user is the owner
      for (final collectionName in collectionsToClean) {
        final collection = _firestore.collection(collectionName);

        try {
          // Try to find documents with the user ID
          final userDocs =
              await collection.where('userId', isEqualTo: userId).get();
          for (final doc in userDocs.docs) {
            batch.delete(doc.reference);
          }

          // Also try with 'agentId' field
          final agentDocs =
              await collection.where('agentId', isEqualTo: userId).get();
          for (final doc in agentDocs.docs) {
            batch.delete(doc.reference);
          }

          // Also try with 'createdBy' field (for products in old structure)
          final createdByDocs =
              await collection.where('createdBy', isEqualTo: userId).get();
          for (final doc in createdByDocs.docs) {
            batch.delete(doc.reference);
          }

          // Try direct document with userId as document ID
          final directDoc = await collection.doc(userId).get();
          if (directDoc.exists) {
            batch.delete(directDoc.reference);
          }

          print('✅ Cleaned collection: $collectionName');
        } catch (e) {
          print('⚠️ Could not clean collection $collectionName: $e');
          // Continue with other collections
        }
      }

      // Delete subcollections within user documents
      await _deleteUserSubcollections(userId, batch);

      // Commit the batch
      await batch.commit();
      print('✅ User data deleted successfully');
    } catch (e) {
      print('❌ Error deleting user data: $e');
      // Don't throw error here as we still want to delete the auth account
    }
  }

  /// Delete from Hushhagents collection and its subcollections
  static Future<void> _deleteHushhAgentsData(
      String userId, WriteBatch batch) async {
    try {
      print('🗑️ Deleting Hushhagents data for: $userId');

      // Delete the main Hushhagents document
      final hushhAgentDoc = _firestore.collection('Hushhagents').doc(userId);
      final hushhAgentSnapshot = await hushhAgentDoc.get();

      if (hushhAgentSnapshot.exists) {
        batch.delete(hushhAgentDoc);

        // Delete agentProducts subcollection
        final agentProductsQuery =
            await hushhAgentDoc.collection('agentProducts').get();
        int agentProductCount = 0;

        for (final productDoc in agentProductsQuery.docs) {
          batch.delete(productDoc.reference);
          agentProductCount++;
        }

        // Delete other subcollections if they exist
        final subcollections = [
          'settings',
          'analytics',
          'notifications',
          'conversations',
        ];

        for (final subcollectionName in subcollections) {
          try {
            final subcollectionQuery =
                await hushhAgentDoc.collection(subcollectionName).get();
            for (final doc in subcollectionQuery.docs) {
              batch.delete(doc.reference);
            }
          } catch (e) {
            print('⚠️ Could not delete subcollection $subcollectionName: $e');
          }
        }

        print(
            '✅ Prepared deletion of Hushhagents/$userId with $agentProductCount agent products');
      } else {
        print('ℹ️ Hushhagents/$userId document does not exist');
      }
    } catch (e) {
      print('⚠️ Error deleting Hushhagents data: $e');
    }
  }

  /// Delete user subcollections
  static Future<void> _deleteUserSubcollections(
      String userId, WriteBatch batch) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userId);

      // List of subcollections to delete
      final subcollections = [
        'posts',
        'followers',
        'following',
        'settings',
        'notifications',
        'messages',
        'chats',
        'analytics',
        'agentProducts',
      ];

      for (final subcollectionName in subcollections) {
        try {
          final subcollection = userDocRef.collection(subcollectionName);
          final docs = await subcollection.get();

          for (final doc in docs.docs) {
            batch.delete(doc.reference);
          }
        } catch (e) {
          print('⚠️ Could not delete subcollection $subcollectionName: $e');
        }
      }
    } catch (e) {
      print('❌ Error deleting subcollections: $e');
    }
  }

  /// Show logout confirmation dialog
  static void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await logout(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  /// Show delete account confirmation dialog
  static void showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and will permanently delete all your data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await deleteAccount(context);
            },
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
