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

  /// Direct delete account functionality with re-authentication handling
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
      }

      // Check if this is a requires-recent-login error
      if (e.toString().contains('requires-recent-login')) {
        if (context.mounted) {
          return await _handleRecentLoginRequired(context);
        }
      } else {
        // Handle other errors
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete account: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      return false;
    }
  }

  /// Handle the requires-recent-login error by prompting for re-authentication
  static Future<bool> _handleRecentLoginRequired(BuildContext context) async {
    try {
      // Show re-authentication dialog
      final shouldProceed = await _showReauthenticationDialog(context);
      if (!shouldProceed) {
        return false;
      }

      // Perform re-authentication
      final success = await _reauthenticateUser(context);
      if (!success) {
        return false;
      }

      // Retry account deletion after re-authentication
      return await deleteAccount(context);
    } catch (e) {
      print('❌ Re-authentication error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Re-authentication failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }

  /// Show dialog explaining re-authentication requirement  
  static Future<bool> _showReauthenticationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFA342FF).withOpacity(0.2),
                    const Color(0xFFE54D60).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFA342FF).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.security,
                color: Color(0xFFA342FF),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Security Verification Required',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For security reasons, you need to verify your identity before deleting your account.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Please sign in again to confirm this action.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFA342FF), Color(0xFFE54D60)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Re-authenticate user based on their sign-in method
  static Future<bool> _reauthenticateUser(BuildContext context) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently signed in');
      }

      // Get user's sign-in methods
      final providerData = currentUser.providerData;
      
      if (providerData.isEmpty) {
        throw Exception('Unable to determine sign-in method');
      }

      final providerId = providerData.first.providerId;
      
      // Handle different authentication providers
      switch (providerId) {
        case 'phone':
          return await _reauthenticateWithPhone(context, currentUser);
        case 'password':
          return await _reauthenticateWithEmail(context, currentUser);
        case 'google.com':
          return await _reauthenticateWithGoogle(context, currentUser);
        default:
          throw Exception('Unsupported authentication provider: $providerId');
      }
    } catch (e) {
      print('❌ Re-authentication error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Re-authentication failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }

  /// Re-authenticate with phone number
  static Future<bool> _reauthenticateWithPhone(BuildContext context, User user) async {
    try {
      // Show phone re-authentication dialog
      final phoneNumber = await _showPhoneReauthDialog(context);
      if (phoneNumber == null) return false;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Sending verification code...'),
            ],
          ),
        ),
      );

      bool verificationCompleted = false;
      String? verificationId;

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await user.reauthenticateWithCredential(credential);
            verificationCompleted = true;
            if (context.mounted) {
              Navigator.pop(context); // Close loading dialog
            }
          } catch (e) {
            print('❌ Auto verification failed: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (context.mounted) {
            Navigator.pop(context); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Verification failed: ${e.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        codeSent: (String verId, int? resendToken) async {
          verificationId = verId;
          if (context.mounted) {
            Navigator.pop(context); // Close loading dialog
            
            // Show OTP input dialog
            final otp = await _showOtpDialog(context);
            if (otp != null && verificationId != null) {
              try {
                final credential = PhoneAuthProvider.credential(
                  verificationId: verificationId!,
                  smsCode: otp,
                );
                await user.reauthenticateWithCredential(credential);
                verificationCompleted = true;
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid OTP: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          }
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
      );

      // Wait for verification to complete (max 60 seconds)
      int waitTime = 0;
      while (!verificationCompleted && waitTime < 60) {
        await Future.delayed(const Duration(seconds: 1));
        waitTime++;
      }

      return verificationCompleted;
    } catch (e) {
      print('❌ Phone re-authentication error: $e');
      if (context.mounted) {
        Navigator.pop(context); // Close any open dialogs
      }
      return false;
    }
  }

  /// Re-authenticate with email and password
  static Future<bool> _reauthenticateWithEmail(BuildContext context, User user) async {
    try {
      final credentials = await _showEmailReauthDialog(context);
      if (credentials == null) return false;

      final credential = EmailAuthProvider.credential(
        email: credentials['email']!,
        password: credentials['password']!,
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      print('❌ Email re-authentication error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email re-authentication failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  /// Re-authenticate with Google
  static Future<bool> _reauthenticateWithGoogle(BuildContext context, User user) async {
    try {
      // For Google re-authentication, we would need GoogleSignIn
      // For now, show a message that this feature is not implemented
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google re-authentication not implemented yet. Please try again later.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return false;
    } catch (e) {
      print('❌ Google re-authentication error: $e');
      return false;
    }
  }

  /// Show phone number input dialog for re-authentication
  static Future<String?> _showPhoneReauthDialog(BuildContext context) async {
    final TextEditingController phoneController = TextEditingController();
    
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Phone Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter your phone number to verify your identity:'),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1234567890',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final phone = phoneController.text.trim();
              if (phone.isNotEmpty) {
                Navigator.of(context).pop(phone);
              }
            },
            child: const Text('Send Code'),
          ),
        ],
      ),
    );
  }

  /// Show OTP input dialog
  static Future<String?> _showOtpDialog(BuildContext context) async {
    final TextEditingController otpController = TextEditingController();
    
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Verification Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter the verification code sent to your phone:'),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Verification Code',
                hintText: '123456',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final otp = otpController.text.trim();
              if (otp.isNotEmpty) {
                Navigator.of(context).pop(otp);
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  /// Show email and password input dialog for re-authentication
  static Future<Map<String, String>?> _showEmailReauthDialog(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    
    return await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-enter Credentials'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please re-enter your email and password:'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              final password = passwordController.text.trim();
              if (email.isNotEmpty && password.isNotEmpty) {
                Navigator.of(context).pop({
                  'email': email,
                  'password': password,
                });
              }
            },
            child: const Text('Authenticate'),
          ),
        ],
      ),
    );
  }

  /// Delete only agent data from Firestore (bypasses Firebase Auth requirements)
  static Future<bool> deleteAgentDataOnly() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        print('❌ No user is currently signed in');
        return false;
      }

      final String userId = user.uid;
      print('🗑️ Starting agent data deletion (Firestore only) for: $userId');
      print('═══════════════════════════════════════════════════════');

      // Delete all agent data from Firestore without touching Firebase Auth
      await _deleteAgentDataFromFirestore(userId);

      print('═══════════════════════════════════════════════════════');
      print('✅ Agent data deletion completed for: $userId');
      return true;
    } catch (e) {
      print('❌ Error deleting agent data: $e');
      return false;
    }
  }

  /// Delete all agent data from Firestore collections only
  static Future<void> _deleteAgentDataFromFirestore(String userId) async {
    try {
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

      print('✅ All agent data successfully removed from Firestore');
    } catch (e) {
      print('❌ Error in agent data deletion: $e');
      throw e;
    }
  }

  /// Delete all user data from Firestore - COMPREHENSIVE VERSION
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
  /// Show dialog for deleting agent data only (no Firebase Auth deletion)
  static void showDeleteAgentDataDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA342FF), Color(0xFFE54D60)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.cleaning_services,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Clean Agent Data',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This will remove all your agent data from the system:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFA342FF).withOpacity(0.1),
                      const Color(0xFFE54D60).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFA342FF).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFA342FF), Color(0xFFE54D60)],
                          ).createShader(bounds),
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Data to be removed:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('• Agent profile and settings', style: TextStyle(color: Colors.black87)),
                    const Text('• All products and inventory', style: TextStyle(color: Colors.black87)),
                    const Text('• Lookbooks and collections', style: TextStyle(color: Colors.black87)),
                    const Text('• Chat conversations', style: TextStyle(color: Colors.black87)),
                    const Text('• Analytics and reports', style: TextStyle(color: Colors.black87)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Your account will remain active',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFA342FF), Color(0xFFE54D60)],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  
                  // Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFA342FF), Color(0xFFE54D60)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Cleaning agent data...',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  );

                  // Delete agent data
                  bool success = await deleteAgentDataOnly();
                  
                  // Close loading dialog
                  Navigator.of(context).pop();
                  
                  if (success) {
                    // Show success dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFA342FF), Color(0xFFE54D60)],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('Data Cleaned Successfully'),
                          ],
                        ),
                        content: const Text(
                          'All your agent data has been removed from the system. Your account remains active and you can create new agent profiles anytime.',
                        ),
                        actions: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFA342FF), Color(0xFFE54D60)],
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                // Navigate to appropriate screen (like onboarding)
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: const Text('OK'),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Show error dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Failed to clean agent data. Please try again.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  'Clean Data',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.delete_forever,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Colors.red,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'This action is permanent',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• All your agent data will be deleted\n• Your profile and settings will be removed\n• Chat history will be permanently lost\n• This action cannot be undone',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await deleteAccount(context);
              },
              child: const Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
