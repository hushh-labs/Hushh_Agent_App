import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'shared/constants/app_routes.dart';
import 'shared/constants/colors.dart';
import 'shared/config/theme/text_theme.dart';
import 'shared/core/routing/routes.dart';
import 'app/features/auth/di/auth_injection.dart' as auth_di;
import 'app/features/splash/domain/dependency/splash_injection.dart'
    as splash_di;
import 'app/Home/di/home_injection.dart' as home_di;
import 'app/features/profile/di/profile_injection.dart' as profile_di;
import 'app/features/inventory/di/inventory_injection.dart' as inventory_di;
import 'app/features/notification_bidding/di/notification_bidding_injection.dart'
    as notification_di;
import 'app/features/notification_bidding/data/datasources/notification_handler_service.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize dependencies
  auth_di.initializeAuthFeature();
  splash_di.initializeSplashFeature();
  await home_di.initializeHomeFeature();
  profile_di.initializeProfileFeature();
  inventory_di.initializeInventoryFeature();
  notification_di.initializeNotificationBiddingFeature();

  // Initialize notification handling
  await _initializeNotificationHandling();

  // Initialize notification handler service
  final notificationHandler = NotificationHandlerService();
  notificationHandler.initializeNotificationHandlers();

  runApp(const MyApp());
}

/// Initialize notification handling
Future<void> _initializeNotificationHandling() async {
  print('🔔 [MAIN] Initializing notification handling...');

  // Request permission for iOS
  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print(
      '🔔 [MAIN] Notification permission status: ${settings.authorizationStatus}');

  // Set up method channel for iOS foreground notifications
  const platform = MethodChannel('notification_handler');
  platform.setMethodCallHandler((call) async {
    if (call.method == 'handleForegroundNotification') {
      print('🔔 [MAIN] Received foreground notification from iOS');
      print('🔔 [MAIN] Notification data: ${call.arguments}');

      final data = Map<String, dynamic>.from(call.arguments);
      final notificationType = data['type'];
      final notificationHandler = NotificationHandlerService();

      switch (notificationType) {
        case 'cart_item_added':
          print(
              '🛒 [MAIN] Cart item added notification from iOS - showing bidding overlay');
          notificationHandler.handleCartItemAddedNotification(data);
          break;
        case 'agent_rejection':
          print(
              '❌ [MAIN] Agent rejection notification from iOS - showing rejection dialog');
          notificationHandler.handleAgentRejectionNotification(data);
          break;
        case 'agent_bid':
          print(
              '💰 [MAIN] Agent bid notification from iOS - showing bid dialog');
          notificationHandler.handleAgentBidNotification(data);
          break;
        default:
          print(
              '🔔 [MAIN] Unknown notification type from iOS: $notificationType');
      }
    }
  });

  // Handle foreground messages - show bidding overlay directly, no notification banner
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('🔔 [MAIN] Received foreground message: ${message.messageId}');
    print('🔔 [MAIN] Message data: ${message.data}');
    print('🔔 [MAIN] Message type: ${message.data['type']}');

    // Check notification type and route to appropriate handler
    final notificationType = message.data['type'];
    final notificationHandler = NotificationHandlerService();

    switch (notificationType) {
      case 'cart_item_added':
        print(
            '🛒 [MAIN] Cart item added notification in foreground - showing bidding overlay directly');
        notificationHandler.handleCartItemAddedNotification(message.data);
        break;
      case 'agent_rejection':
        print(
            '❌ [MAIN] Agent rejection notification in foreground - showing rejection dialog');
        notificationHandler.handleAgentRejectionNotification(message.data);
        break;
      case 'agent_bid':
        print(
            '💰 [MAIN] Agent bid notification in foreground - showing bid dialog');
        notificationHandler.handleAgentBidNotification(message.data);
        break;
      default:
        print('🔔 [MAIN] Unknown notification type: $notificationType');
    }
  });

  // Handle when app is opened from notification (background/closed app)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('🔔 [MAIN] App opened from notification: ${message.messageId}');
    print('🔔 [MAIN] Message data: ${message.data}');
    print('🔔 [MAIN] Message type: ${message.data['type']}');
    print('🔔 [MAIN] All message keys: ${message.data.keys.toList()}');

    // Check notification type and route to appropriate handler
    final notificationType = message.data['type'];

    switch (notificationType) {
      case 'cart_item_added':
        print('🛒 [MAIN] Cart item added notification opened in main');
        print(
            '🛒 [MAIN] Navigator key available: ${navigatorKey.currentContext != null}');
        _handleNotificationWithNavigation(message.data);
        break;
      case 'agent_rejection':
        print('❌ [MAIN] Agent rejection notification opened in main');
        _handleNotificationWithNavigation(message.data);
        break;
      case 'agent_bid':
        print('💰 [MAIN] Agent bid notification opened in main');
        _handleNotificationWithNavigation(message.data);
        break;
      default:
        print('🔔 [MAIN] Unknown notification type: $notificationType');
    }
  });

  // Handle initial message when app is launched from notification
  final initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    print(
        '🔔 [MAIN] App launched from notification: ${initialMessage.messageId}');
    print('🔔 [MAIN] Message data: ${initialMessage.data}');
    print('🔔 [MAIN] Message type: ${initialMessage.data['type']}');
    print(
        '🔔 [MAIN] All initial message keys: ${initialMessage.data.keys.toList()}');

    // Check notification type and route to appropriate handler
    final notificationType = initialMessage.data['type'];

    switch (notificationType) {
      case 'cart_item_added':
        print('🛒 [MAIN] Cart item added notification launched app in main');
        print(
            '🛒 [MAIN] Navigator key available: ${navigatorKey.currentContext != null}');
        _handleNotificationWithNavigation(initialMessage.data);
        break;
      case 'agent_rejection':
        print('❌ [MAIN] Agent rejection notification launched app in main');
        _handleNotificationWithNavigation(initialMessage.data);
        break;
      case 'agent_bid':
        print('💰 [MAIN] Agent bid notification launched app in main');
        _handleNotificationWithNavigation(initialMessage.data);
        break;
      default:
        print('🔔 [MAIN] Unknown initial message type: $notificationType');
    }
  }

  print('🔔 [MAIN] Notification handling initialized');
}

/// Handle notification with navigation to dashboard
void _handleNotificationWithNavigation(Map<String, dynamic> data) {
  print('🔔 [MAIN] Handling notification with navigation');
  final notificationType = data['type'];

  // Show appropriate overlay after a short delay to let the app open normally
  Future.delayed(const Duration(milliseconds: 1500), () {
    print(
        '🔔 [MAIN] Showing overlay after app opened for type: $notificationType');
    final notificationHandler = NotificationHandlerService();

    switch (notificationType) {
      case 'cart_item_added':
        notificationHandler.handleCartItemAddedNotification(data);
        break;
      case 'agent_rejection':
        notificationHandler.handleAgentRejectionNotification(data);
        break;
      case 'agent_bid':
        notificationHandler.handleAgentBidNotification(data);
        break;
      default:
        print('🔔 [MAIN] Unknown notification type: $notificationType');
    }
  });
}

// Global navigator key for showing dialogs from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hushh Agent',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: CustomColors.primary,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
