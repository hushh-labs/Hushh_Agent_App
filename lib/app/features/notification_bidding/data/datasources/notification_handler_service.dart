import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/services.dart';
import '../../../../../main.dart';
import 'dart:io' show Platform;

/// Notification Handler Service
///
/// IMPORTANT: When testing notifications, ensure that userId and agentId are different:
/// - userId: Should be the customer's UID (who added item to cart)
/// - agentId: Should be the agent's UID (who receives the notification)
///
/// In a real scenario:
/// 1. Customer adds item to cart → Customer's UID is userId
/// 2. Agent receives notification → Agent's UID is agentId
/// 3. Agent responds with bid/rejection → Notification sent back to customer's UID
///
/// NOTIFICATION FLOW:
/// Customer App → Cloud Function → Agent App (shows bidding overlay)
/// Agent App → Cloud Function → Customer App (sends bid/rejection notification)
///
/// Use testRealScenarioNotification() for proper testing with different UIDs.
class NotificationHandlerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isShowingOverlay = false; // Flag to prevent duplicate overlays
  String? _currentNotificationId; // Track current notification ID

  /// Initialize notification handlers
  void initializeNotificationHandlers() {
    print('🔔 [NOTIFICATION] Initializing notification handlers...');

    // Note: All notification handling is now done in main.dart
    // to prevent duplicate overlays and ensure proper handling

    // Check for pending notifications from UserDefaults (iOS workaround)
    checkForPendingNotifications();

    print('🔔 [NOTIFICATION] Notification handlers initialized');
  }

  /// Check for pending notifications from UserDefaults (iOS workaround)
  Future<void> checkForPendingNotifications() async {
    try {
      const platform = MethodChannel('notification_handler');
      final result = await platform.invokeMethod('getPendingNotificationData');

      if (result != null && result is Map<String, dynamic>) {
        print('🔔 [NOTIFICATION] Found pending notification data: $result');

        final notificationType = result['type'];
        switch (notificationType) {
          case 'cart_item_added':
            print(
                '🛒 [NOTIFICATION] Processing pending cart item notification');
            handleCartItemAddedNotification(result);
            break;
          case 'agent_rejection':
            print(
                '❌ [NOTIFICATION] Processing pending agent rejection notification');
            handleAgentRejectionNotification(result);
            break;
          case 'agent_bid':
            print(
                '💰 [NOTIFICATION] Processing pending agent bid notification');
            handleAgentBidNotification(result);
            break;
          default:
            print(
                '🔔 [NOTIFICATION] Unknown pending notification type: $notificationType');
        }

        // Clear the pending notification
        await platform.invokeMethod('clearPendingNotificationData');
      }
    } catch (e) {
      print('❌ [NOTIFICATION] Error checking pending notifications: $e');
    }
  }

  /// Test function to simulate a cart item added notification
  void testCartItemAddedNotification() {
    print('🧪 [NOTIFICATION] Testing cart item added notification');

    final testData = {
      'notificationId':
          'test_notification_${DateTime.now().millisecondsSinceEpoch}',
      'userId': 'test_user_id',
      'userName': 'Test User',
      'productId': 'test_product_id',
      'productName': 'Test Product',
      'productPrice': '100.0',
      'quantity': '1',
      'agentId': 'test_agent_id',
      'agentName': 'Test Agent',
      'timestamp': DateTime.now().toIso8601String(),
    };

    handleCartItemAddedNotification(testData);
  }

  /// Test function to simulate a real scenario with different UIDs
  void testRealScenarioNotification() {
    print('🧪 [NOTIFICATION] Testing real scenario with different UIDs');

    // Get current user's UID (this will be the agent's UID)
    final currentUser = FirebaseAuth.instance.currentUser;
    final agentId = currentUser?.uid ?? 'current_agent_id';
    final agentName = currentUser?.displayName ?? 'Current Agent';

    // Create a fake customer UID (different from agent)
    final customerId = 'customer_${DateTime.now().millisecondsSinceEpoch}';
    final customerName = 'Test Customer';

    final testData = {
      'notificationId':
          'cart_item_added_${customerId}_test_product_${DateTime.now().millisecondsSinceEpoch}',
      'type': 'cart_item_added',
      'userId': customerId, // Customer's UID (different from agent)
      'userName': customerName,
      'productId': 'test_product_id',
      'productName': 'Test Product',
      'productPrice': '100.0',
      'quantity': '1',
      'agentId': agentId, // Agent's UID (current user)
      'agentName': agentName,
      'timestamp': DateTime.now().toIso8601String(),
      'action': 'view_cart',
      'showBiddingInterface': 'true'
    };

    print('🧪 [NOTIFICATION] Test data with different UIDs:');
    print('🧪 [NOTIFICATION] Customer UID: $customerId');
    print('🧪 [NOTIFICATION] Agent UID: $agentId');
    print('🧪 [NOTIFICATION] Full test data: $testData');

    handleCartItemAddedNotification(testData);
  }

  /// Debug function to show current user's UID
  void debugCurrentUserUID() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print('🔍 [DEBUG] Current User UID: ${currentUser.uid}');
      print('🔍 [DEBUG] Current User Name: ${currentUser.displayName}');
      print('🔍 [DEBUG] Current User Email: ${currentUser.email}');
    } else {
      print('🔍 [DEBUG] No current user logged in');
    }
  }

  /// Test Firebase Functions connectivity
  Future<void> testFirebaseFunctionsConnectivity() async {
    try {
      print('🔍 [DEBUG] Testing Firebase Functions connectivity...');

      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      print('✅ [DEBUG] Functions instance created with region: us-central1');

      // Test with minimal data
      final testData = {
        'productId': 'test_product_${DateTime.now().millisecondsSinceEpoch}',
        'productName': 'Test Product',
        'productPrice': '100.0',
        'agentId': 'test_agent',
        'agentName': 'Test Agent',
        'userId': 'test_user',
        'userName': 'Test User',
        'bidAmount': 50.0,
        'quantity': '1',
      };

      print('🔍 [DEBUG] Testing saveAgentBid with data: $testData');
      final callable = functions.httpsCallable('saveAgentBid');
      final result = await callable.call(testData);
      print(
          '✅ [DEBUG] Firebase Functions connectivity test successful: ${result.data}');
    } catch (e) {
      print('❌ [DEBUG] Firebase Functions connectivity test failed: $e');
      print('❌ [DEBUG] Error type: ${e.runtimeType}');
      print('❌ [DEBUG] Error details: $e');
    }
  }

  /// Test Firebase Functions deployment
  Future<void> testFunctionsDeployment() async {
    try {
      print('🔍 [DEBUG] Testing Firebase Functions deployment...');

      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      print('✅ [DEBUG] Functions instance created with region: us-central1');

      // Test if functions are accessible
      final functionsToTest = ['saveAgentBid', 'sendCartItemNotification'];

      for (final functionName in functionsToTest) {
        try {
          print('🔍 [DEBUG] Testing function: $functionName');
          final callable = functions.httpsCallable(functionName);
          print('✅ [DEBUG] Function $functionName is accessible');
        } catch (e) {
          print('❌ [DEBUG] Function $functionName is not accessible: $e');
        }
      }
    } catch (e) {
      print('❌ [DEBUG] Functions deployment test failed: $e');
      print('❌ [DEBUG] Error type: ${e.runtimeType}');
      print('❌ [DEBUG] Error details: $e');
    }
  }

  /// Test basic Firebase connectivity
  Future<void> testBasicFirebaseConnectivity() async {
    try {
      print('🔍 [DEBUG] Testing basic Firebase connectivity...');

      // Test Firestore
      final firestore = FirebaseFirestore.instance;
      print('✅ [DEBUG] Firestore instance accessible');

      // Test Auth
      final auth = FirebaseAuth.instance;
      print('✅ [DEBUG] Auth instance accessible');

      // Test Functions
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      print('✅ [DEBUG] Functions instance accessible');

      print('✅ [DEBUG] All Firebase services are accessible');
    } catch (e) {
      print('❌ [DEBUG] Basic Firebase connectivity test failed: $e');
      print('❌ [DEBUG] Error type: ${e.runtimeType}');
      print('❌ [DEBUG] Error details: $e');
    }
  }

  /// Test iOS Firebase Functions specifically
  Future<void> testIOSFirebaseFunctions() async {
    try {
      print('🔍 [DEBUG] Testing iOS Firebase Functions...');

      // Check if we're on iOS
      if (Platform.isIOS) {
        print('✅ [DEBUG] Running on iOS platform');
      } else {
        print('⚠️ [DEBUG] Not running on iOS platform');
      }

      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      print('✅ [DEBUG] Functions instance created with region: us-central1');

      // Test with minimal data
      final testData = {
        'productId':
            'ios_test_product_${DateTime.now().millisecondsSinceEpoch}',
        'productName': 'iOS Test Product',
        'productPrice': '100.0',
        'agentId': 'ios_test_agent',
        'agentName': 'iOS Test Agent',
        'userId': 'ios_test_user',
        'userName': 'iOS Test User',
        'bidAmount': 50.0,
        'quantity': '1',
      };

      print('🔍 [DEBUG] Testing iOS saveAgentBid with data: $testData');
      final callable = functions.httpsCallable('saveAgentBid');
      final result = await callable.call(testData);
      print('✅ [DEBUG] iOS Firebase Functions test successful: ${result.data}');
    } catch (e) {
      print('❌ [DEBUG] iOS Firebase Functions test failed: $e');
      print('❌ [DEBUG] Error type: ${e.runtimeType}');
      print('❌ [DEBUG] Error details: $e');
    }
  }

  /// Test simple function call
  Future<void> testSimpleFunctionCall() async {
    try {
      print('🔍 [DEBUG] Testing simple Firebase Functions call...');

      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      print('✅ [DEBUG] Functions instance created with region: us-central1');

      // Try a simple function that might exist
      final callable = functions.httpsCallable('sendCartItemNotification');
      print('✅ [DEBUG] Callable function created');

      // Test with minimal data
      final testData = {
        'productId':
            'simple_test_product_${DateTime.now().millisecondsSinceEpoch}',
        'productName': 'Simple Test Product',
        'productPrice': '100.0',
        'agentId': 'simple_test_agent',
        'agentName': 'Simple Test Agent',
        'userId': 'simple_test_user',
        'userName': 'Simple Test User',
        'quantity': '1',
      };

      print('🔍 [DEBUG] Testing simple function call with data: $testData');
      final result = await callable.call(testData);
      print('✅ [DEBUG] Simple function call successful: ${result.data}');
    } catch (e) {
      print('❌ [DEBUG] Simple function call failed: $e');
      print('❌ [DEBUG] Error type: ${e.runtimeType}');
      print('❌ [DEBUG] Error details: $e');

      // Check if it's a function not found error
      if (e.toString().contains('not found') || e.toString().contains('404')) {
        print('❌ [DEBUG] Function not found - check deployment');
      } else if (e.toString().contains('connection') ||
          e.toString().contains('channel')) {
        print('❌ [DEBUG] Connection issue - check iOS configuration');
      } else {
        print('❌ [DEBUG] Other error - check function implementation');
      }
    }
  }

  /// Test the new saveAgentBid function
  Future<void> testSaveAgentBid() async {
    try {
      print('🔍 [DEBUG] Testing saveAgentBid function...');

      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      print('✅ [DEBUG] Functions instance created with region: us-central1');

      // Test the new saveAgentBid function
      final callable = functions.httpsCallable('saveAgentBid');
      print('✅ [DEBUG] saveAgentBid callable function created');

      // Test with minimal data
      final testData = {
        'productId': 'test_product_${DateTime.now().millisecondsSinceEpoch}',
        'productName': 'Test Product',
        'productPrice': '100.0',
        'agentId': 'test_agent',
        'agentName': 'Test Agent',
        'userId': 'test_user',
        'userName': 'Test User',
        'bidAmount': 50.0,
        'quantity': '1',
      };

      print('🔍 [DEBUG] Testing saveAgentBid with data: $testData');
      print(
          '🔍 [DEBUG] This will save to Realtime Database AND send notification to user');
      final result = await callable.call(testData);
      print('✅ [DEBUG] saveAgentBid successful: ${result.data}');

      // Check if the response contains the expected data
      if (result.data is Map) {
        final data = result.data as Map;
        if (data['success'] == true) {
          print('✅ [DEBUG] Bid saved successfully with ID: ${data['bidId']}');
          print('✅ [DEBUG] Bid data: ${data['data']}');
          print('✅ [DEBUG] Message: ${data['message']}');
          print('✅ [DEBUG] Notification should have been sent to user');
        } else {
          print('❌ [DEBUG] Bid save failed: ${data['error']}');
        }
      }
    } catch (e) {
      print('❌ [DEBUG] saveAgentBid test failed: $e');
      print('❌ [DEBUG] Error type: ${e.runtimeType}');
      print('❌ [DEBUG] Error details: $e');

      if (e.toString().contains('connection') ||
          e.toString().contains('channel')) {
        print('❌ [DEBUG] Connection issue - check Firebase configuration');
      } else if (e.toString().contains('not found')) {
        print('❌ [DEBUG] Function not found - check deployment');
      } else {
        print('❌ [DEBUG] Other error - check function implementation');
      }
    }
  }

  /// Validate notification data UIDs
  void validateNotificationUIDs(Map<String, dynamic> notificationData) {
    final userId = notificationData['userId'];
    final agentId = notificationData['agentId'];

    if (userId == agentId) {
      print('⚠️ [WARNING] userId and agentId are the same: $userId');
      print(
          '⚠️ [WARNING] This might indicate a testing scenario where the agent is using their own UID for both fields');
      print('⚠️ [WARNING] In a real scenario, these should be different:');
      print('⚠️ [WARNING] - userId: Customer\'s UID (who added item to cart)');
      print('⚠️ [WARNING] - agentId: Agent\'s UID (who receives notification)');
    } else {
      print(
          '✅ [VALIDATION] UIDs are different - this looks like a real scenario');
      print('✅ [VALIDATION] Customer UID: $userId');
      print('✅ [VALIDATION] Agent UID: $agentId');
    }
  }

  /// Test function to simulate notification data from Firebase Cloud Function
  void testFirebaseCloudFunctionNotification() {
    print(
        '🧪 [NOTIFICATION] Testing Firebase Cloud Function notification format');

    final testData = {
      'notificationId':
          'cart_item_added_test_user_123_${DateTime.now().millisecondsSinceEpoch}',
      'type': 'cart_item_added',
      'userId': 'test_user_123',
      'userName': 'John Doe',
      'productId': 'product_456',
      'productName': 'iPhone 15 Pro',
      'productPrice': '999.99',
      'quantity': '1',
      'agentId': 'agent_789',
      'agentName': 'Tech Store Agent',
      'timestamp': DateTime.now().toIso8601String(),
      'action': 'view_cart',
      'showBiddingInterface': 'true'
    };

    handleCartItemAddedNotification(testData);
  }

  /// Test function to simulate real notification data format
  void testRealNotificationData() {
    print('🧪 [NOTIFICATION] Testing real notification data format');

    final testData = {
      'notificationId': 'cart_item_added_user123_product456_1234567890',
      'type': 'cart_item_added',
      'userId': 'user123',
      'userName': 'John Doe',
      'productId': 'product456',
      'productName': 'iPhone 15 Pro',
      'productPrice': '999.99',
      'quantity': '1',
      'agentId': 'agent789',
      'agentName': 'Tech Store Agent',
      'timestamp': '2024-01-01T12:00:00.000Z',
      'action': 'view_cart',
      'showBiddingInterface': 'true'
    };

    print('🧪 [NOTIFICATION] Test data: $testData');
    handleCartItemAddedNotification(testData);
  }

  /// Simple method to show bidding overlay immediately (for testing)
  void showBiddingOverlayNow() {
    print('🧪 [NOTIFICATION] Showing bidding overlay immediately');

    final testData = {
      'notificationId':
          'test_immediate_${DateTime.now().millisecondsSinceEpoch}',
      'type': 'cart_item_added',
      'userId': 'test_user',
      'userName': 'Test Customer',
      'productId': 'test_product',
      'productName': 'Test Product',
      'productPrice': '100.0',
      'quantity': '1',
      'agentId': 'test_agent',
      'agentName': 'Test Agent',
      'timestamp': DateTime.now().toIso8601String(),
    };

    _showBiddingInterface(testData);
  }

  /// Test method using different approach to show dialog
  void testDialogWithDifferentApproach() {
    print('🧪 [NOTIFICATION] Testing dialog with different approach');

    final testData = {
      'notificationId':
          'test_different_${DateTime.now().millisecondsSinceEpoch}',
      'type': 'cart_item_added',
      'userId': 'test_user',
      'userName': 'Test Customer',
      'productId': 'test_product',
      'productName': 'Test Product',
      'productPrice': '100.0',
      'quantity': '1',
      'agentId': 'test_agent',
      'agentName': 'Test Agent',
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Try using Navigator.of(context) approach
    if (navigatorKey.currentContext != null) {
      print('🧪 [NOTIFICATION] Using Navigator.of(context) approach');
      Navigator.of(navigatorKey.currentContext!).push(
        PageRouteBuilder(
          opaque: false,
          barrierDismissible: false,
          pageBuilder: (context, animation, secondaryAnimation) {
            return BiddingDialog(notificationData: testData);
          },
        ),
      );
    } else {
      print(
          '❌ [NOTIFICATION] Navigator context not available for different approach');
    }
  }

  /// Debug method to log all notification data
  void debugNotificationData(Map<String, dynamic> data) {
    print('🔍 [DEBUG] === NOTIFICATION DATA DEBUG ===');
    print('🔍 [DEBUG] Data type: ${data['type']}');
    print('🔍 [DEBUG] All keys: ${data.keys.toList()}');

    // Check for common data formats
    if (data.containsKey('aps')) {
      print('🔍 [DEBUG] Found aps field: ${data['aps']}');
    }

    if (data.containsKey('notification')) {
      print('🔍 [DEBUG] Found notification field: ${data['notification']}');
    }

    print('🔍 [DEBUG] === END DEBUG ===');
  }

  /// Handle cart item added notification
  void handleCartItemAddedNotification(Map<String, dynamic> data) {
    print('🛒 [NOTIFICATION] Handling cart item added notification');

    // Debug the incoming data
    debugNotificationData(data);

    print('🛒 [NOTIFICATION] Data: $data');
    print('🛒 [NOTIFICATION] Data type: ${data['type']}');
    print(
        '🛒 [NOTIFICATION] Navigator key available: ${navigatorKey.currentContext != null}');

    // Extract notification data with fallbacks for different data formats
    Map<String, dynamic> notificationData;

    // Check if data is nested in a 'data' field (iOS format)
    if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
      print('🛒 [NOTIFICATION] Found nested data field, extracting...');
      final nestedData = data['data'] as Map<String, dynamic>;
      notificationData = {
        'notificationId': nestedData['notificationId'] ??
            'notification_${DateTime.now().millisecondsSinceEpoch}',
        'userId': nestedData['userId'] ?? 'unknown_user',
        'userName': nestedData['userName'] ?? 'Customer',
        'productId': nestedData['productId'] ?? 'unknown_product',
        'productName': nestedData['productName'] ?? 'Product',
        'productPrice': nestedData['productPrice']?.toString() ?? '0.0',
        'quantity': nestedData['quantity']?.toString() ?? '1',
        'agentId': nestedData['agentId'] ?? 'unknown_agent',
        'agentName': nestedData['agentName'] ?? 'Agent',
        'timestamp':
            nestedData['timestamp'] ?? DateTime.now().toIso8601String(),
      };
    } else {
      // Direct data format
      notificationData = {
        'notificationId': data['notificationId'] ??
            'notification_${DateTime.now().millisecondsSinceEpoch}',
        'userId': data['userId'] ?? 'unknown_user',
        'userName': data['userName'] ?? 'Customer',
        'productId': data['productId'] ?? 'unknown_product',
        'productName': data['productName'] ?? 'Product',
        'productPrice': data['productPrice']?.toString() ?? '0.0',
        'quantity': data['quantity']?.toString() ?? '1',
        'agentId': data['agentId'] ?? 'unknown_agent',
        'agentName': data['agentName'] ?? 'Agent',
        'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
      };
    }

    print('🛒 [NOTIFICATION] Extracted notification data: $notificationData');
    print(
        '🛒 [NOTIFICATION] Navigator key current context: ${navigatorKey.currentContext != null ? 'Available' : 'Null'}');

    // Validate UIDs
    validateNotificationUIDs(notificationData);

    // Show bidding interface
    _showBiddingInterface(notificationData);
  }

  /// Handle agent rejection notification
  void handleAgentRejectionNotification(Map<String, dynamic> data) {
    print('❌ [NOTIFICATION] Handling agent rejection notification');

    // Debug the incoming data
    debugNotificationData(data);

    // Extract notification data with fallbacks for different data formats
    Map<String, dynamic> notificationData;

    // Check if data is nested in a 'data' field (iOS format)
    if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
      print('❌ [NOTIFICATION] Found nested data field, extracting...');
      final nestedData = data['data'] as Map<String, dynamic>;
      notificationData = {
        'notificationId': nestedData['notificationId'] ??
            'notification_${DateTime.now().millisecondsSinceEpoch}',
        'userId': nestedData['userId'] ?? 'unknown_user',
        'userName': nestedData['userName'] ?? 'Customer',
        'productId': nestedData['productId'] ?? 'unknown_product',
        'productName': nestedData['productName'] ?? 'Product',
        'productPrice': nestedData['productPrice']?.toString() ?? '0.0',
        'agentId': nestedData['agentId'] ?? 'unknown_agent',
        'agentName': nestedData['agentName'] ?? 'Agent',
        'reason': nestedData['reason'] ?? 'Agent is not available',
        'timestamp':
            nestedData['timestamp'] ?? DateTime.now().toIso8601String(),
      };
    } else {
      // Direct data format
      notificationData = {
        'notificationId': data['notificationId'] ??
            'notification_${DateTime.now().millisecondsSinceEpoch}',
        'userId': data['userId'] ?? 'unknown_user',
        'userName': data['userName'] ?? 'Customer',
        'productId': data['productId'] ?? 'unknown_product',
        'productName': data['productName'] ?? 'Product',
        'productPrice': data['productPrice']?.toString() ?? '0.0',
        'agentId': data['agentId'] ?? 'unknown_agent',
        'agentName': data['agentName'] ?? 'Agent',
        'reason': data['reason'] ?? 'Agent is not available',
        'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
      };
    }

    print('❌ [NOTIFICATION] Extracted notification data: $notificationData');

    // Show rejection interface
    _showRejectionInterface(notificationData);
  }

  /// Handle agent bid notification
  void handleAgentBidNotification(Map<String, dynamic> data) {
    print('💰 [NOTIFICATION] Handling agent bid notification');

    // Debug the incoming data
    debugNotificationData(data);

    // Extract notification data with fallbacks for different data formats
    Map<String, dynamic> notificationData;

    // Check if data is nested in a 'data' field (iOS format)
    if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
      print('💰 [NOTIFICATION] Found nested data field, extracting...');
      final nestedData = data['data'] as Map<String, dynamic>;
      notificationData = {
        'notificationId': nestedData['notificationId'] ??
            'notification_${DateTime.now().millisecondsSinceEpoch}',
        'userId': nestedData['userId'] ?? 'unknown_user',
        'userName': nestedData['userName'] ?? 'Customer',
        'productId': nestedData['productId'] ?? 'unknown_product',
        'productName': nestedData['productName'] ?? 'Product',
        'productPrice': nestedData['productPrice']?.toString() ?? '0.0',
        'agentId': nestedData['agentId'] ?? 'unknown_agent',
        'agentName': nestedData['agentName'] ?? 'Agent',
        'bidAmount': nestedData['bidAmount']?.toString() ?? '0',
        'quantity': nestedData['quantity']?.toString() ?? '1',
        'expiresAt': nestedData['expiresAt'] ??
            DateTime.now().add(Duration(hours: 24)).toIso8601String(),
        'timestamp':
            nestedData['timestamp'] ?? DateTime.now().toIso8601String(),
      };
    } else {
      // Direct data format
      notificationData = {
        'notificationId': data['notificationId'] ??
            'notification_${DateTime.now().millisecondsSinceEpoch}',
        'userId': data['userId'] ?? 'unknown_user',
        'userName': data['userName'] ?? 'Customer',
        'productId': data['productId'] ?? 'unknown_product',
        'productName': data['productName'] ?? 'Product',
        'productPrice': data['productPrice']?.toString() ?? '0.0',
        'agentId': data['agentId'] ?? 'unknown_agent',
        'agentName': data['agentName'] ?? 'Agent',
        'bidAmount': data['bidAmount']?.toString() ?? '0',
        'quantity': data['quantity']?.toString() ?? '1',
        'expiresAt': data['expiresAt'] ??
            DateTime.now().add(Duration(hours: 24)).toIso8601String(),
        'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
      };
    }

    print('💰 [NOTIFICATION] Extracted notification data: $notificationData');

    // Validate UIDs
    validateNotificationUIDs(notificationData);

    // Show bid interface
    _showBidInterface(notificationData);
  }

  /// Check if app is in foreground
  bool _isAppInForeground() {
    // This is a simple check - you might want to implement a more robust solution
    return navigatorKey.currentContext != null;
  }

  /// Show bidding interface modal
  void _showBiddingInterface(Map<String, dynamic> notificationData) {
    print('🛒 [NOTIFICATION] Showing bidding interface');
    print('🛒 [NOTIFICATION] Navigator key: $navigatorKey');
    print(
        '🛒 [NOTIFICATION] Navigator key current context: ${navigatorKey.currentContext}');
    print(
        '🛒 [NOTIFICATION] Navigator key current state: ${navigatorKey.currentState}');

    final notificationId = notificationData['notificationId'] as String?;

    // Prevent duplicate overlays
    if (_isShowingOverlay) {
      print('⚠️ [NOTIFICATION] Overlay already showing, skipping duplicate');
      return;
    }

    // Prevent duplicate overlays for same notification
    if (_currentNotificationId == notificationId) {
      print(
          '⚠️ [NOTIFICATION] Same notification already showing, skipping duplicate');
      return;
    }

    // Use the global navigator key to show the dialog
    if (navigatorKey.currentContext != null) {
      print('✅ [NOTIFICATION] Navigator context is available, showing dialog');

      _isShowingOverlay = true; // Set flag to prevent duplicates
      _currentNotificationId = notificationId; // Track current notification

      // Add a small delay to ensure the app is fully loaded
      Future.delayed(const Duration(milliseconds: 500), () {
        if (navigatorKey.currentContext != null) {
          print('✅ [NOTIFICATION] Showing dialog after delay');
          showDialog(
            context: navigatorKey.currentContext!,
            barrierDismissible: true, // Allow dismissing by tapping outside
            useSafeArea: true,
            barrierColor: Colors.black54, // Semi-transparent background
            builder: (BuildContext context) {
              print('✅ [NOTIFICATION] Dialog builder called');
              return BiddingDialog(notificationData: notificationData);
            },
          ).then((_) {
            // Reset flags when dialog is closed
            _isShowingOverlay = false;
            _currentNotificationId = null;
          });
          print('✅ [NOTIFICATION] Dialog shown successfully');
        } else {
          print('❌ [NOTIFICATION] Navigator context became null after delay');
          _isShowingOverlay = false; // Reset flag
          _currentNotificationId = null;
        }
      });
    } else {
      print(
          '❌ [NOTIFICATION] Navigator context is null, cannot show bidding dialog');
      print('❌ [NOTIFICATION] Navigator key: $navigatorKey');
      print(
          '❌ [NOTIFICATION] Navigator key current state: ${navigatorKey.currentState}');

      // Try again after a short delay in case the context becomes available
      Future.delayed(const Duration(seconds: 1), () {
        print('🔄 [NOTIFICATION] Retrying to show dialog...');
        print(
            '🔄 [NOTIFICATION] Navigator context available: ${navigatorKey.currentContext != null}');
        if (navigatorKey.currentContext != null) {
          _showBiddingInterface(notificationData);
        } else {
          print(
              '❌ [NOTIFICATION] Still cannot show bidding dialog after retry');
        }
      });
    }
  }

  /// Show rejection interface modal
  void _showRejectionInterface(Map<String, dynamic> notificationData) {
    print('❌ [NOTIFICATION] Showing rejection interface');

    final notificationId = notificationData['notificationId'] as String?;

    // Prevent duplicate overlays
    if (_isShowingOverlay) {
      print('⚠️ [NOTIFICATION] Overlay already showing, skipping duplicate');
      return;
    }

    // Prevent duplicate overlays for same notification
    if (_currentNotificationId == notificationId) {
      print(
          '⚠️ [NOTIFICATION] Same notification already showing, skipping duplicate');
      return;
    }

    // Use the global navigator key to show the dialog
    if (navigatorKey.currentContext != null) {
      print(
          '✅ [NOTIFICATION] Navigator context is available, showing rejection dialog');

      _isShowingOverlay = true; // Set flag to prevent duplicates
      _currentNotificationId = notificationId; // Track current notification

      // Add a small delay to ensure the app is fully loaded
      Future.delayed(const Duration(milliseconds: 500), () {
        if (navigatorKey.currentContext != null) {
          print('✅ [NOTIFICATION] Showing rejection dialog after delay');
          showDialog(
            context: navigatorKey.currentContext!,
            barrierDismissible: true, // Allow dismissing by tapping outside
            useSafeArea: true,
            barrierColor: Colors.black54, // Semi-transparent background
            builder: (BuildContext context) {
              print('✅ [NOTIFICATION] Rejection dialog builder called');
              return RejectionDialog(notificationData: notificationData);
            },
          ).then((_) {
            // Reset flags when dialog is closed
            _isShowingOverlay = false;
            _currentNotificationId = null;
          });
          print('✅ [NOTIFICATION] Rejection dialog shown successfully');
        } else {
          print('❌ [NOTIFICATION] Navigator context became null after delay');
          _isShowingOverlay = false; // Reset flag
          _currentNotificationId = null;
        }
      });
    } else {
      print(
          '❌ [NOTIFICATION] Navigator context is null, cannot show rejection dialog');

      // Try again after a short delay in case the context becomes available
      Future.delayed(const Duration(seconds: 1), () {
        print('🔄 [NOTIFICATION] Retrying to show rejection dialog...');
        print(
            '🔄 [NOTIFICATION] Navigator context available: ${navigatorKey.currentContext != null}');
        if (navigatorKey.currentContext != null) {
          _showRejectionInterface(notificationData);
        } else {
          print(
              '❌ [NOTIFICATION] Still cannot show rejection dialog after retry');
        }
      });
    }
  }

  /// Show bid interface modal
  void _showBidInterface(Map<String, dynamic> notificationData) {
    print('💰 [NOTIFICATION] Showing bid interface');

    final notificationId = notificationData['notificationId'] as String?;

    // Prevent duplicate overlays
    if (_isShowingOverlay) {
      print('⚠️ [NOTIFICATION] Overlay already showing, skipping duplicate');
      return;
    }

    // Prevent duplicate overlays for same notification
    if (_currentNotificationId == notificationId) {
      print(
          '⚠️ [NOTIFICATION] Same notification already showing, skipping duplicate');
      return;
    }

    // Use the global navigator key to show the dialog
    if (navigatorKey.currentContext != null) {
      print(
          '✅ [NOTIFICATION] Navigator context is available, showing bid dialog');

      _isShowingOverlay = true; // Set flag to prevent duplicates
      _currentNotificationId = notificationId; // Track current notification

      // Add a small delay to ensure the app is fully loaded
      Future.delayed(const Duration(milliseconds: 500), () {
        if (navigatorKey.currentContext != null) {
          print('✅ [NOTIFICATION] Showing bid dialog after delay');
          showDialog(
            context: navigatorKey.currentContext!,
            barrierDismissible: true, // Allow dismissing by tapping outside
            useSafeArea: true,
            barrierColor: Colors.black54, // Semi-transparent background
            builder: (BuildContext context) {
              print('✅ [NOTIFICATION] Bid dialog builder called');
              return BidDialog(notificationData: notificationData);
            },
          ).then((_) {
            // Reset flags when dialog is closed
            _isShowingOverlay = false;
            _currentNotificationId = null;
          });
          print('✅ [NOTIFICATION] Bid dialog shown successfully');
        } else {
          print('❌ [NOTIFICATION] Navigator context became null after delay');
          _isShowingOverlay = false; // Reset flag
          _currentNotificationId = null;
        }
      });
    } else {
      print(
          '❌ [NOTIFICATION] Navigator context is null, cannot show bid dialog');

      // Try again after a short delay in case the context becomes available
      Future.delayed(const Duration(seconds: 1), () {
        print('🔄 [NOTIFICATION] Retrying to show bid dialog...');
        print(
            '🔄 [NOTIFICATION] Navigator context available: ${navigatorKey.currentContext != null}');
        if (navigatorKey.currentContext != null) {
          _showBidInterface(notificationData);
        } else {
          print('❌ [NOTIFICATION] Still cannot show bid dialog after retry');
        }
      });
    }
  }
}

/// Bidding Dialog Widget
class BiddingDialog extends StatefulWidget {
  final Map<String, dynamic> notificationData;

  const BiddingDialog({
    super.key,
    required this.notificationData,
  });

  @override
  State<BiddingDialog> createState() => _BiddingDialogState();
}

class _BiddingDialogState extends State<BiddingDialog> {
  final TextEditingController _bidController = TextEditingController();
  final FocusNode _bidFocusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _bidController.dispose();
    _bidFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isKeyboardOpen ? 16 : 24,
        vertical: isKeyboardOpen ? 8 : 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          minHeight: 200,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: keyboardHeight,
            ),
            child: GestureDetector(
              onTap: () {
                // Dismiss keyboard when tapping outside
                FocusScope.of(context).unfocus();
              },
              child: Padding(
                padding: EdgeInsets.all(isKeyboardOpen ? 20 : 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isKeyboardOpen ? 10 : 12),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.shopping_cart,
                            color: Colors.purple,
                            size: isKeyboardOpen ? 28 : 32,
                          ),
                        ),
                        SizedBox(width: isKeyboardOpen ? 12 : 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Item Added to Cart!',
                                style: TextStyle(
                                  fontSize: isKeyboardOpen ? 18 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: isKeyboardOpen ? 2 : 4),
                              Text(
                                '${widget.notificationData['userName']} is interested in your product',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: isKeyboardOpen ? 13 : 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            size: isKeyboardOpen ? 20 : 24,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isKeyboardOpen ? 16 : 24),

                    // Product Details
                    Text(
                      'Product Details',
                      style: TextStyle(
                        fontSize: isKeyboardOpen ? 15 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: isKeyboardOpen ? 8 : 12),
                    _buildDetailRow(
                        'Product', widget.notificationData['productName']),
                    _buildDetailRow('Price',
                        '\$${widget.notificationData['productPrice']}'),
                    _buildDetailRow(
                        'Customer', widget.notificationData['userName']),
                    SizedBox(height: isKeyboardOpen ? 16 : 24),

                    // Bid Section
                    Text(
                      'Place Your Bid',
                      style: TextStyle(
                        fontSize: isKeyboardOpen ? 15 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(height: isKeyboardOpen ? 6 : 8),
                    Text(
                      'Offer hushh coins to encourage this customer to purchase your product:',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isKeyboardOpen ? 13 : 14,
                      ),
                    ),
                    SizedBox(height: isKeyboardOpen ? 12 : 16),
                    TextField(
                      controller: _bidController,
                      focusNode: _bidFocusNode,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submitBid(),
                      autofocus: true,
                      style: TextStyle(
                        fontSize: isKeyboardOpen ? 16 : 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Bid Amount (hushh coins)',
                        hintStyle: TextStyle(
                          fontSize: isKeyboardOpen ? 14 : 16,
                          color: Colors.grey[500],
                        ),
                        prefixIcon:
                            const Icon(Icons.attach_money, color: Colors.amber),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _bidController.clear(),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isKeyboardOpen ? 14 : 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Colors.purple, width: 2),
                        ),
                      ),
                    ),
                    SizedBox(height: isKeyboardOpen ? 16 : 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => _handleAgentRejection(),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: isKeyboardOpen ? 14 : 16,
                              ),
                              side: const BorderSide(color: Colors.purple),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.purple),
                            ),
                          ),
                        ),
                        SizedBox(width: isKeyboardOpen ? 12 : 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitBid,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: isKeyboardOpen ? 14 : 16,
                              ),
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text('Submit Bid'),
                          ),
                        ),
                      ],
                    ),
                    // Add extra padding at bottom for keyboard
                    SizedBox(height: isKeyboardOpen ? 16 : 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitBid() async {
    final bidAmount = _bidController.text.trim();

    if (bidAmount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a bid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bidValue = double.tryParse(bidAmount);
    if (bidValue == null || bidValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid bid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Save bid to Firestore
      await _saveBidToFirestore(bidValue);

      // Send notification to user about the bid
      await _sendBidNotificationToUser(bidValue);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bid submitted successfully! User will be notified.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit bid: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _sendBidNotificationToUser(double bidAmount) async {
    try {
      print(
          '✅ [BID] Saving bid to Realtime Database and sending notification: $bidAmount hushh coins');
      print(
          '✅ [BID] Customer UID (who will receive notification): ${widget.notificationData['userId']}');
      print('✅ [BID] Customer Name: ${widget.notificationData['userName']}');
      print(
          '✅ [BID] Agent UID (who is sending the bid): ${widget.notificationData['agentId']}');
      print('✅ [BID] Agent Name: ${widget.notificationData['agentName']}');
      print('✅ [BID] Product: ${widget.notificationData['productName']}');
      print('✅ [BID] Full notification data: ${widget.notificationData}');

      // Call the cloud function using Firebase Functions SDK with explicit region
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      print('✅ [BID] Initializing Firebase Functions for region: us-central1');

      final callable = functions.httpsCallable('saveAgentBid');
      print('✅ [BID] Callable function created successfully');

      final callData = {
        'productId': widget.notificationData['productId'],
        'productName': widget.notificationData['productName'],
        'productPrice': widget.notificationData['productPrice'],
        'agentId': widget.notificationData['agentId'], // Agent's UID
        'agentName': widget.notificationData['agentName'], // Agent's name
        'userId': widget.notificationData[
            'userId'], // Customer's UID (who receives notification)
        'userName': widget.notificationData['userName'], // Customer's name
        'bidAmount': bidAmount,
        'quantity': widget.notificationData['quantity'],
      };

      print('✅ [BID] Calling cloud function with data: $callData');
      print(
          '✅ [BID] This will save to Realtime Database AND send notification to user');
      final result = await callable.call(callData);
      print(
          '✅ [BID] Bid saved and notification sent successfully: ${result.data}');
      print(
          '✅ [BID] Bid saved to Realtime Database and notification sent to customer UID: ${widget.notificationData['userId']}');
    } catch (e) {
      print('❌ [BID] Failed to save bid and send notification: $e');
      print('❌ [BID] Error type: ${e.runtimeType}');
      print('❌ [BID] Error details: $e');

      // Check if it's a connection error
      if (e.toString().contains('connection') ||
          e.toString().contains('channel')) {
        print(
            '❌ [BID] This appears to be a Firebase Functions connection issue');
        print('❌ [BID] Please check:');
        print('❌ [BID] 1. Firebase project configuration');
        print('❌ [BID] 2. Cloud Functions deployment');
        print('❌ [BID] 3. Network connectivity');
        print('❌ [BID] 4. iOS-specific Firebase configuration');
      }

      throw e;
    }
  }

  Future<void> _handleAgentRejection() async {
    try {
      print('❌ [REJECTION] Agent rejected the cart item');
      print('❌ [REJECTION] Customer UID: ${widget.notificationData['userId']}');
      print(
          '❌ [REJECTION] Customer Name: ${widget.notificationData['userName']}');
      print('❌ [REJECTION] Agent UID: ${widget.notificationData['agentId']}');
      print(
          '❌ [REJECTION] Agent Name: ${widget.notificationData['agentName']}');
      print('❌ [REJECTION] Product: ${widget.notificationData['productName']}');
      print('❌ [REJECTION] Full notification data: ${widget.notificationData}');

      // For now, just log the rejection - we can implement rejection logic later
      print('❌ [REJECTION] Agent rejection logged - no action taken');

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rejection logged'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('❌ [REJECTION] Failed to handle rejection: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to handle rejection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveBidToFirestore(double bidAmount) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    final now = DateTime.now();
    final expiry = now.add(const Duration(hours: 24));

    // Create bid data
    final bidData = {
      'userId': widget.notificationData['userId'],
      'agentId': currentUser.uid,
      'bidAmount': bidAmount,
      'expiry': Timestamp.fromDate(expiry),
      'status': 'sent',
      'productId': widget.notificationData['productId'],
      'productName': widget.notificationData['productName'],
      'productPrice': widget.notificationData['productPrice'],
      'customerName': widget.notificationData['userName'],
      'createdAt': Timestamp.fromDate(now),
      'notificationId': widget.notificationData['notificationId'],
    };

    // Save to Firestore
    await FirebaseFirestore.instance.collection('bids').add(bidData);

    print('✅ [BID] Bid saved successfully: $bidAmount hushh coins');
  }
}

/// Rejection Dialog Widget
class RejectionDialog extends StatelessWidget {
  final Map<String, dynamic> notificationData;

  const RejectionDialog({
    super.key,
    required this.notificationData,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isKeyboardOpen ? 16 : 24,
        vertical: isKeyboardOpen ? 8 : 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          minHeight: 200,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: keyboardHeight,
            ),
            child: Padding(
              padding: EdgeInsets.all(isKeyboardOpen ? 20 : 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isKeyboardOpen ? 10 : 12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.cancel_outlined,
                          color: Colors.red,
                          size: isKeyboardOpen ? 28 : 32,
                        ),
                      ),
                      SizedBox(width: isKeyboardOpen ? 12 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Agent Unavailable',
                              style: TextStyle(
                                fontSize: isKeyboardOpen ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: isKeyboardOpen ? 2 : 4),
                            Text(
                              'We\'ll find you another agent',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isKeyboardOpen ? 13 : 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          size: isKeyboardOpen ? 20 : 24,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isKeyboardOpen ? 16 : 24),

                  // Product Details
                  Text(
                    'Product Details',
                    style: TextStyle(
                      fontSize: isKeyboardOpen ? 15 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: isKeyboardOpen ? 8 : 12),
                  _buildDetailRow('Product', notificationData['productName']),
                  _buildDetailRow(
                      'Price', '\$${notificationData['productPrice']}'),
                  _buildDetailRow('Agent', notificationData['agentName']),
                  SizedBox(height: isKeyboardOpen ? 16 : 24),

                  // Message
                  Container(
                    padding: EdgeInsets.all(isKeyboardOpen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.red,
                              size: isKeyboardOpen ? 16 : 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Agent Status',
                              style: TextStyle(
                                fontSize: isKeyboardOpen ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${notificationData['agentName']} is currently unavailable for ${notificationData['productName']}. We\'ll automatically find you another agent who can help you with this product.',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: isKeyboardOpen ? 13 : 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isKeyboardOpen ? 16 : 24),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isKeyboardOpen ? 14 : 16,
                        ),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Got it'),
                    ),
                  ),
                  // Add extra padding at bottom for keyboard
                  SizedBox(height: isKeyboardOpen ? 16 : 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bid Dialog Widget
class BidDialog extends StatelessWidget {
  final Map<String, dynamic> notificationData;

  const BidDialog({
    super.key,
    required this.notificationData,
  });

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isKeyboardOpen ? 16 : 24,
        vertical: isKeyboardOpen ? 8 : 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          minHeight: 200,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: keyboardHeight,
            ),
            child: Padding(
              padding: EdgeInsets.all(isKeyboardOpen ? 20 : 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isKeyboardOpen ? 10 : 12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.monetization_on,
                          color: Colors.amber[700],
                          size: isKeyboardOpen ? 28 : 32,
                        ),
                      ),
                      SizedBox(width: isKeyboardOpen ? 12 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hushh Coins Offer!',
                              style: TextStyle(
                                fontSize: isKeyboardOpen ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[700],
                              ),
                            ),
                            SizedBox(height: isKeyboardOpen ? 2 : 4),
                            Text(
                              'Valid for 24 hours',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isKeyboardOpen ? 13 : 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          size: isKeyboardOpen ? 20 : 24,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isKeyboardOpen ? 16 : 24),

                  // Product Details
                  Text(
                    'Product Details',
                    style: TextStyle(
                      fontSize: isKeyboardOpen ? 15 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: isKeyboardOpen ? 8 : 12),
                  _buildDetailRow('Product', notificationData['productName']),
                  _buildDetailRow(
                      'Price', '\$${notificationData['productPrice']}'),
                  _buildDetailRow('Agent', notificationData['agentName']),
                  SizedBox(height: isKeyboardOpen ? 16 : 24),

                  // Bid Offer
                  Container(
                    padding: EdgeInsets.all(isKeyboardOpen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: Colors.amber[700],
                              size: isKeyboardOpen ? 16 : 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Your Offer',
                              style: TextStyle(
                                fontSize: isKeyboardOpen ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${notificationData['agentName']} has offered you ${notificationData['bidAmount']} hushh coins for ${notificationData['productName']}!',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: isKeyboardOpen ? 13 : 14,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This offer is valid for 24 hours and will be automatically applied at checkout.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: isKeyboardOpen ? 12 : 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isKeyboardOpen ? 16 : 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: isKeyboardOpen ? 14 : 16,
                            ),
                            side: BorderSide(color: Colors.amber[700]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'View Later',
                            style: TextStyle(color: Colors.amber[700]),
                          ),
                        ),
                      ),
                      SizedBox(width: isKeyboardOpen ? 12 : 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Navigate to product page or cart
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: isKeyboardOpen ? 14 : 16,
                            ),
                            backgroundColor: Colors.amber[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('View Product'),
                        ),
                      ),
                    ],
                  ),
                  // Add extra padding at bottom for keyboard
                  SizedBox(height: isKeyboardOpen ? 16 : 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
