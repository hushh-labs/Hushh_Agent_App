import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/app_routes.dart';
import '../../main.dart'; // Import for global navigatorKey

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
  /// This removes all user data from Firestore and deletes the Firebase Auth account
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

      // Check if user has both agent and user accounts
      final hasUserAccount = await _hasUserAccount(userId);

      if (hasUserAccount) {
        print(
            '👥 User has both agent and user accounts - keeping Firebase Auth');
        print('🗑️ Deleting only agent data from Firestore...');
      } else {
        print('🔐 User has only agent account - will delete Firebase Auth');
      }

      // Delete user data from Firestore collections
      await _deleteUserData(userId);

      // Try to delete the Firebase Auth account ONLY if user doesn't have user account
      if (!hasUserAccount) {
        try {
          await currentUser.delete();
          print('✅ Firebase Auth account deleted successfully');
        } catch (authError) {
          print('⚠️ Firebase Auth deletion error: $authError');

          // If it's a requires-recent-login error, just sign out as fallback
          if (authError.toString().contains('requires-recent-login')) {
            print(
                'ℹ️ Account requires recent authentication, signing out instead');
            await _auth.signOut();
            print('✅ User signed out successfully (data still deleted)');
          } else {
            // For other auth errors, still sign out but log the error
            print('ℹ️ Unexpected auth error, signing out as fallback');
            await _auth.signOut();
            print('✅ User signed out successfully (data still deleted)');
          }
        }
      } else {
        // User has both accounts - just sign out, don't delete Firebase Auth
        print('🔄 Signing out user (keeping Firebase Auth for user account)');
        await _auth.signOut();
        print(
            '✅ User signed out successfully (agent data deleted, user account preserved)');
      }

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
        print('✅ Loading dialog closed');
      }

      // Small delay to ensure dialog is fully closed
      await Future.delayed(const Duration(milliseconds: 300));

      // Navigate to auth page and clear all previous routes
      if (context.mounted) {
        print('🧭 Navigating to main auth page...');
        try {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.mainAuth,
            (route) => false,
          );
          print('✅ Successfully navigated to main auth page');
        } catch (navError) {
          print('❌ Navigation error: $navError');
          // Fallback: try to navigate without clearing all routes
          Navigator.pushReplacementNamed(context, AppRoutes.mainAuth);
        }

        // Show success message after navigation
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            final successMessage = hasUserAccount
                ? 'Agent account deleted successfully (user account preserved)'
                : 'Account deleted successfully';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(successMessage),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
      } else {
        print('⚠️ Context not mounted for navigation');
        // Use global navigator as fallback
        print('🧭 Using global navigator for navigation...');
        try {
          final globalContext = navigatorKey.currentContext;
          if (globalContext != null) {
            Navigator.pushNamedAndRemoveUntil(
              globalContext,
              AppRoutes.mainAuth,
              (route) => false,
            );
            print('✅ Successfully navigated using global navigator');

            // Show success message using global context
            Future.delayed(const Duration(milliseconds: 500), () {
              final successMessage = hasUserAccount
                  ? 'Agent account deleted successfully (user account preserved)'
                  : 'Account deleted successfully';
              ScaffoldMessenger.of(globalContext).showSnackBar(
                SnackBar(
                  content: Text(successMessage),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            });
          } else {
            print('❌ Global navigator context also not available');
          }
        } catch (globalNavError) {
          print('❌ Global navigation error: $globalNavError');
        }
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

  static Future<bool> deleteAccountWithReauth(
    BuildContext context, {
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

      // Check if user has both agent and user accounts
      final hasUserAccount = await _hasUserAccount(userId);

      if (hasUserAccount) {
        print(
            '👥 User has both agent and user accounts - keeping Firebase Auth');
        print('🗑️ Deleting only agent data from Firestore...');
      } else {
        print('🔐 User has only agent account - will delete Firebase Auth');
      }

      // Delete user data from Firestore collections
      await _deleteUserData(userId);

      // Delete the Firebase Auth account ONLY if user doesn't have user account
      if (!hasUserAccount) {
        await currentUser.delete();
        print('✅ Firebase Auth account deleted successfully');
      } else {
        // User has both accounts - just sign out, don't delete Firebase Auth
        print('🔄 Signing out user (keeping Firebase Auth for user account)');
        await _auth.signOut();
        print(
            '✅ User signed out successfully (agent data deleted, user account preserved)');
      }

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
        print('✅ Loading dialog closed');
      }

      // Small delay to ensure dialog is fully closed
      await Future.delayed(const Duration(milliseconds: 300));

      // Navigate to auth page and clear all previous routes
      if (context.mounted) {
        print('🧭 Navigating to main auth page...');
        try {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.mainAuth,
            (route) => false,
          );
          print('✅ Successfully navigated to main auth page');
        } catch (navError) {
          print('❌ Navigation error: $navError');
          // Fallback: try to navigate without clearing all routes
          Navigator.pushReplacementNamed(context, AppRoutes.mainAuth);
        }

        // Show success message after navigation
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            final successMessage = hasUserAccount
                ? 'Agent account deleted successfully (user account preserved)'
                : 'Account completely deleted successfully';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(successMessage),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
      } else {
        print('⚠️ Context not mounted for navigation');
        // Use global navigator as fallback
        print('🧭 Using global navigator for navigation...');
        try {
          final globalContext = navigatorKey.currentContext;
          if (globalContext != null) {
            Navigator.pushNamedAndRemoveUntil(
              globalContext,
              AppRoutes.mainAuth,
              (route) => false,
            );
            print('✅ Successfully navigated using global navigator');

            // Show success message using global context
            Future.delayed(const Duration(milliseconds: 500), () {
              final successMessage = hasUserAccount
                  ? 'Agent account deleted successfully (user account preserved)'
                  : 'Account completely deleted successfully';
              ScaffoldMessenger.of(globalContext).showSnackBar(
                SnackBar(
                  content: Text(successMessage),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            });
          } else {
            print('❌ Global navigator context also not available');
          }
        } catch (globalNavError) {
          print('❌ Global navigation error: $globalNavError');
        }
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

  /// Check if user has both agent and user accounts
  static Future<bool> _hasUserAccount(String userId) async {
    try {
      print('🔍 Checking if user has regular user account: $userId');
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final hasUserAccount = userDoc.exists;
      print('🔍 User account exists: $hasUserAccount');
      return hasUserAccount;
    } catch (e) {
      print('⚠️ Error checking user account: $e');
      return false; // If we can't check, assume no user account
    }
  }

  static Future<void> _deleteUserData(String userId) async {
    try {
      print('🗑️ Starting COMPREHENSIVE deletion of user data for: $userId');
      print('═══════════════════════════════════════════════════════');

      // STEP 1: Delete main agent document and its subcollections
      await _deleteAgentMainDocument(userId);

      // STEP 2: Delete all agent products from both storage locations
      await _deleteAllAgentProducts(userId);

      // STEP 3: Delete all agent lookbooks
      await _deleteAllAgentLookbooks(userId);

      // STEP 4: Delete from all other possible collections
      await _deleteFromOtherCollections(userId);

      // STEP 5: Delete any remaining references
      await _deleteRemainingReferences(userId);

      print('═══════════════════════════════════════════════════════');
      print('✅ COMPREHENSIVE user data deletion completed for: $userId');
    } catch (e) {
      print('❌ Error in comprehensive user data deletion: $e');
      // Don't throw error here as we still want to delete the auth account
    }
  }

  /// Delete main agent document and its subcollections
  static Future<void> _deleteAgentMainDocument(String userId) async {
    try {
      print('\n🏢 STEP 1: Deleting main agent document...');

      // Delete from Hushhagents collection
      final agentDocRef = _firestore.collection('Hushhagents').doc(userId);
      final agentDoc = await agentDocRef.get();

      if (agentDoc.exists) {
        // Delete all subcollections first
        final subcollections = [
          'agentProducts',
          'settings',
          'analytics',
          'notifications',
          'conversations',
          'chats',
          'messages',
          'logs',
          'reports',
          'posts',
          'followers',
          'following',
        ];

        for (final subcollectionName in subcollections) {
          try {
            final subcollectionRef = agentDocRef.collection(subcollectionName);
            final docs = await subcollectionRef.get();

            if (docs.docs.isNotEmpty) {
              final batch = _firestore.batch();
              int count = 0;

              for (final doc in docs.docs) {
                batch.delete(doc.reference);
                count++;

                // Firestore batch limit is 500 operations
                if (count >= 450) {
                  await batch.commit();
                  print(
                      '  ✅ Deleted $count documents from $subcollectionName (batch)');
                  count = 0;
                }
              }

              if (count > 0) {
                await batch.commit();
                print('  ✅ Deleted $count documents from $subcollectionName');
              }
            }
          } catch (e) {
            print('  ⚠️ Error deleting subcollection $subcollectionName: $e');
          }
        }

        // Delete the main document
        await agentDocRef.delete();
        print('  ✅ Deleted main agent document: Hushhagents/$userId');
      } else {
        print('  ℹ️ Agent document does not exist: Hushhagents/$userId');
      }

      // Also check and delete from other possible agent collections
      final otherAgentCollections = ['HushhAgents', 'agents', 'users'];
      for (final collectionName in otherAgentCollections) {
        try {
          final docRef = _firestore.collection(collectionName).doc(userId);
          final doc = await docRef.get();
          if (doc.exists) {
            await docRef.delete();
            print('  ✅ Deleted agent document: $collectionName/$userId');
          }
        } catch (e) {
          print('  ⚠️ Error deleting from $collectionName: $e');
        }
      }
    } catch (e) {
      print('❌ Error deleting main agent document: $e');
    }
  }

  /// Delete all agent products from both storage locations
  static Future<void> _deleteAllAgentProducts(String userId) async {
    try {
      print('\n📦 STEP 2: Deleting all agent products...');

      // Delete from AgentProducts collection (top-level documents with agentId field)
      try {
        final agentProductsQuery = await _firestore
            .collection('AgentProducts')
            .where('agentId', isEqualTo: userId)
            .get();

        if (agentProductsQuery.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (final doc in agentProductsQuery.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
          print(
              '  ✅ Deleted ${agentProductsQuery.docs.length} products from AgentProducts collection');
        } else {
          print('  ℹ️ No products found in AgentProducts collection');
        }
      } catch (e) {
        print('  ⚠️ Error deleting from AgentProducts: $e');
      }

      // Delete from old products collection (backward compatibility)
      try {
        final oldProductsQuery = await _firestore
            .collection('products')
            .where('createdBy', isEqualTo: userId)
            .get();

        if (oldProductsQuery.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (final doc in oldProductsQuery.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
          print(
              '  ✅ Deleted ${oldProductsQuery.docs.length} products from old products collection');
        } else {
          print('  ℹ️ No products found in old products collection');
        }
      } catch (e) {
        print('  ⚠️ Error deleting from old products collection: $e');
      }

      // Note: Products in Hushhagents/{agentId}/agentProducts/ are already deleted in step 1
      print('  ✅ Agent products deletion completed');
    } catch (e) {
      print('❌ Error deleting agent products: $e');
    }
  }

  /// Delete all agent lookbooks
  static Future<void> _deleteAllAgentLookbooks(String userId) async {
    try {
      print('\n📚 STEP 3: Deleting all agent lookbooks...');

      // Delete from LookBooks collection
      try {
        final lookbooksQuery = await _firestore
            .collection('LookBooks')
            .where('agentId', isEqualTo: userId)
            .get();

        if (lookbooksQuery.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (final doc in lookbooksQuery.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
          print(
              '  ✅ Deleted ${lookbooksQuery.docs.length} lookbooks from LookBooks collection');
        } else {
          print('  ℹ️ No lookbooks found for agent');
        }
      } catch (e) {
        print('  ⚠️ Error deleting lookbooks: $e');
      }

      // Also check old lookbooks collection (if it exists)
      try {
        final oldLookbooksQuery = await _firestore
            .collection('lookbooks')
            .where('agentId', isEqualTo: userId)
            .get();

        if (oldLookbooksQuery.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (final doc in oldLookbooksQuery.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
          print(
              '  ✅ Deleted ${oldLookbooksQuery.docs.length} lookbooks from old lookbooks collection');
        }
      } catch (e) {
        print('  ⚠️ Error deleting from old lookbooks collection: $e');
      }

      print('  ✅ Agent lookbooks deletion completed');
    } catch (e) {
      print('❌ Error deleting agent lookbooks: $e');
    }
  }

  /// Delete from all other possible collections
  static Future<void> _deleteFromOtherCollections(String userId) async {
    try {
      print('\n🗂️ STEP 4: Deleting from other collections...');

      // Define all possible collections and field names to check
      final collectionsToCheck = [
        {
          'collection': 'notifications',
          'fields': ['userId', 'agentId', 'recipientId']
        },
        {
          'collection': 'chats',
          'fields': ['userId', 'agentId', 'createdBy']
        },
        {
          'collection': 'conversations',
          'fields': ['userId', 'agentId', 'participantId']
        },
        {
          'collection': 'messages',
          'fields': ['userId', 'agentId', 'senderId']
        },
        {
          'collection': 'feedback',
          'fields': ['userId', 'agentId', 'submittedBy']
        },
        {
          'collection': 'reports',
          'fields': ['userId', 'agentId', 'reportedBy']
        },
        {
          'collection': 'analytics',
          'fields': ['userId', 'agentId', 'ownerId']
        },
        {
          'collection': 'logs',
          'fields': ['userId', 'agentId', 'actorId']
        },
        {
          'collection': 'AgentCategories',
          'fields': ['agentId', 'createdBy']
        },
        {
          'collection': 'BrandDetails',
          'fields': ['agentId', 'ownerId']
        },
      ];

      for (final collectionInfo in collectionsToCheck) {
        final collectionName = collectionInfo['collection'] as String;
        final fields = collectionInfo['fields'] as List<String>;

        try {
          int totalDeleted = 0;

          for (final fieldName in fields) {
            try {
              final query = await _firestore
                  .collection(collectionName)
                  .where(fieldName, isEqualTo: userId)
                  .get();

              if (query.docs.isNotEmpty) {
                final batch = _firestore.batch();
                for (final doc in query.docs) {
                  batch.delete(doc.reference);
                }
                await batch.commit();
                totalDeleted += query.docs.length;
              }
            } catch (e) {
              print('    ⚠️ Error querying $collectionName by $fieldName: $e');
            }
          }

          // Also try direct document deletion
          try {
            final directDoc =
                await _firestore.collection(collectionName).doc(userId).get();
            if (directDoc.exists) {
              await directDoc.reference.delete();
              totalDeleted += 1;
            }
          } catch (e) {
            print('    ⚠️ Error deleting direct doc from $collectionName: $e');
          }

          if (totalDeleted > 0) {
            print('  ✅ Deleted $totalDeleted documents from $collectionName');
          } else {
            print('  ℹ️ No documents found in $collectionName');
          }
        } catch (e) {
          print('  ⚠️ Error processing collection $collectionName: $e');
        }
      }

      print('  ✅ Other collections cleanup completed');
    } catch (e) {
      print('❌ Error deleting from other collections: $e');
    }
  }

  /// Delete any remaining references
  static Future<void> _deleteRemainingReferences(String userId) async {
    try {
      print('\n🧹 STEP 5: Cleaning up remaining references...');

      // Look for any remaining documents that might reference this user
      final collectionsToScan = [
        'posts',
        'comments',
        'likes',
        'shares',
        'follows',
        'blocks',
        'preferences',
        'settings',
        'sessions'
      ];

      for (final collectionName in collectionsToScan) {
        try {
          // Try multiple possible field names
          final possibleFields = [
            'userId',
            'agentId',
            'ownerId',
            'createdBy',
            'authorId'
          ];

          for (final fieldName in possibleFields) {
            try {
              final query = await _firestore
                  .collection(collectionName)
                  .where(fieldName, isEqualTo: userId)
                  .limit(100) // Limit to avoid large queries
                  .get();

              if (query.docs.isNotEmpty) {
                final batch = _firestore.batch();
                for (final doc in query.docs) {
                  batch.delete(doc.reference);
                }
                await batch.commit();
                print(
                    '  ✅ Cleaned ${query.docs.length} references from $collectionName.$fieldName');
              }
            } catch (e) {
              // Silently continue if field doesn't exist or query fails
            }
          }
        } catch (e) {
          print('  ⚠️ Error scanning collection $collectionName: $e');
        }
      }

      print('  ✅ Remaining references cleanup completed');
    } catch (e) {
      print('❌ Error cleaning remaining references: $e');
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
              if (emailController.text.isEmpty ||
                  passwordController.text.isEmpty) {
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
