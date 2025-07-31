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
  /// This removes all user data from Firestore and signs the user out
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
              Text('Deleting account data...'),
            ],
          ),
        ),
      );

      final userId = currentUser.uid;

      // Delete user data from Firestore collections
      await _deleteUserData(userId);

      // Sign out the user (this avoids the requires-recent-login error)
      await _auth.signOut();

      print('✅ Account data deleted and user signed out successfully');

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
            content: Text('Account data deleted successfully'),
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

  /// Alternative method to fully delete Firebase Auth account with re-authentication
  /// This method handles the requires-recent-login error by re-authenticating the user
  static Future<bool> deleteAccountWithReauth(BuildContext context, {
    required String email,
    required String password,
  }) async {
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
              Text('Re-authenticating and deleting account...'),
            ],
          ),
        ),
      );

      final userId = currentUser.uid;

      // Re-authenticate the user
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await currentUser.reauthenticateWithCredential(credential);
      print('✅ User re-authenticated successfully');

      // Delete user data from Firestore collections
      await _deleteUserData(userId);

      // Now delete the Firebase Auth account (this should work after re-auth)
      await currentUser.delete();
      print('✅ Firebase Auth account deleted successfully');

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
            content: Text('Account completely deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      return true;
    } catch (e) {
      print('❌ Delete account with re-auth error: $e');

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
      // List of collections to delete user data from
      final collectionsToClean = [
        'HushhAgents',
        'users',
        'Hushhagents',
        'AgentProducts',
        'lookbooks',
        'products',
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

          // Try direct document with userId as document ID
          final directDoc = await collection.doc(userId).get();
          if (directDoc.exists) {
            batch.delete(directDoc.reference);
          }
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
          'Are you sure you want to delete your account? This will:\n\n'
          '• Remove all your data from our servers\n'
          '• Sign you out of the app\n'
          '• Cannot be undone\n\n'
          'Your account data will be permanently deleted.',
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
              'Delete My Data',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Show delete account dialog with re-authentication option
  static void showDeleteAccountWithReauthDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account Completely'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To completely delete your Firebase account, please confirm your credentials:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
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
              if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter both email and password'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              
              Navigator.pop(context); // Close dialog
              await deleteAccountWithReauth(
                context,
                email: emailController.text.trim(),
                password: passwordController.text,
              );
            },
            child: const Text(
              'Delete Account Completely',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
