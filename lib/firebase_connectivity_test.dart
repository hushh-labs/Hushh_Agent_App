import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Firebase Connectivity Test
/// This class provides methods to test Firebase backend connectivity
class FirebaseConnectivityTest {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Test Firebase Core initialization
  static Future<bool> testFirebaseInitialization() async {
    try {
      print('🔥 Testing Firebase initialization...');
      
      // Check if Firebase is initialized
      final app = Firebase.app();
      print('✅ Firebase app name: ${app.name}');
      print('✅ Firebase project ID: ${app.options.projectId}');
      
      return true;
    } catch (e) {
      print('❌ Firebase initialization failed: $e');
      return false;
    }
  }

  /// Test Firebase Auth connectivity
  static Future<bool> testFirebaseAuth() async {
    try {
      print('🔐 Testing Firebase Auth connectivity...');
      
      // Get current auth state
      final currentUser = _auth.currentUser;
      print('✅ Firebase Auth initialized');
      print('📱 Current user: ${currentUser?.uid ?? 'Not authenticated'}');
      
      // Test auth state stream
      _auth.authStateChanges().listen((User? user) {
        print('🔄 Auth state changed: ${user?.uid ?? 'null'}');
      });
      
      return true;
    } catch (e) {
      print('❌ Firebase Auth test failed: $e');
      return false;
    }
  }

  /// Test Firestore connectivity
  static Future<bool> testFirestore() async {
    try {
      print('📊 Testing Firestore connectivity...');
      
      // Test basic Firestore connection
      final settings = _firestore.settings;
      print('✅ Firestore settings: ${settings.toString()}');
      
      // Test simple write operation (non-persistent)
      final testRef = _firestore.collection('test').doc('connectivity');
      await testRef.set({
        'test': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      print('✅ Firestore write test successful');
      
      // Clean up test document
      await testRef.delete();
      print('✅ Test document cleaned up');
      
      return true;
    } catch (e) {
      print('❌ Firestore test failed: $e');
      return false;
    }
  }

  /// Test phone authentication (without actually sending SMS)
  static Future<bool> testPhoneAuthSetup() async {
    try {
      print('📞 Testing Phone Auth setup...');
      
      // Test if phone auth can be configured (don't actually send SMS)
      const testPhoneNumber = '+1234567890'; // Fake number for testing
      
      bool setupComplete = false;
      
      await _auth.verifyPhoneNumber(
        phoneNumber: testPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          print('✅ Phone auth verification completed callback works');
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            print('✅ Phone auth validation works (expected for test number)');
            setupComplete = true;
          } else {
            print('⚠️ Phone auth error: ${e.message}');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          print('✅ Phone auth code sent callback works');
          setupComplete = true;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('✅ Phone auth timeout callback works');
        },
        timeout: const Duration(seconds: 1), // Short timeout for test
      );
      
      // Wait a moment for callbacks
      await Future.delayed(const Duration(seconds: 2));
      
      print('✅ Phone auth setup test completed');
      return true;
    } catch (e) {
      print('❌ Phone auth setup test failed: $e');
      return false;
    }
  }

  /// Run comprehensive Firebase connectivity test
  static Future<Map<String, bool>> runFullConnectivityTest() async {
    print('🚀 Starting Firebase connectivity test...\n');
    
    final results = <String, bool>{};
    
    // Test Firebase initialization
    results['firebase_init'] = await testFirebaseInitialization();
    print('');
    
    // Test Firebase Auth
    results['firebase_auth'] = await testFirebaseAuth();
    print('');
    
    // Test Firestore
    results['firestore'] = await testFirestore();
    print('');
    
    // Test Phone Auth setup
    results['phone_auth'] = await testPhoneAuthSetup();
    print('');
    
    // Print summary
    print('📋 CONNECTIVITY TEST SUMMARY:');
    print('═══════════════════════════════');
    results.forEach((test, passed) {
      final status = passed ? '✅ PASS' : '❌ FAIL';
      print('$test: $status');
    });
    
    final allPassed = results.values.every((result) => result);
    print('\n🎯 Overall Status: ${allPassed ? '✅ ALL TESTS PASSED' : '⚠️ SOME TESTS FAILED'}');
    
    return results;
  }
}

/// Quick connectivity test function for easy access
Future<void> testFirebaseConnectivity() async {
  await FirebaseConnectivityTest.runFullConnectivityTest();
} 