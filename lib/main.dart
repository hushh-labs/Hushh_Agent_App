import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'shared/constants/app_routes.dart';
import 'shared/constants/colors.dart';
import 'shared/config/theme/text_theme.dart';
import 'shared/core/routing/routes.dart';
import 'app/features/auth/di/auth_injection.dart' as auth_di;
import 'app/features/splash/domain/dependency/splash_injection.dart' as splash_di;
import 'app/Home/di/home_injection.dart' as home_di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Suppress Flutter keyboard event errors (known Flutter framework issue)
  FlutterError.onError = (FlutterErrorDetails details) {
    // Suppress keyboard event assertion errors
    if (details.exception.toString().contains('KeyUpEvent is dispatched') ||
        details.exception.toString().contains('_pressedKeys.containsKey') ||
        details.exception.toString().contains('HardwareKeyboard') ||
        details.exception.toString().contains('KeyDownEvent is dispatched') ||
        details.exception.toString().contains('_assertEventIsRegular')) {
      // Silently ignore these known Flutter framework issues
      return;
    }
    // Log other errors normally
    FlutterError.presentError(details);
  };
  
  // Handle platform exceptions (including keyboard events)
  PlatformDispatcher.instance.onError = (error, stack) {
    if (error.toString().contains('KeyUpEvent') ||
        error.toString().contains('KeyDownEvent') ||
        error.toString().contains('HardwareKeyboard')) {
      // Silently ignore keyboard-related platform errors
      return true;
    }
    // Return false for other errors to be handled normally
    return false;
  };
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize dependencies
  auth_di.initializeAuthFeature();
  splash_di.initializeSplashFeature();
  await home_di.initializeHomeFeature();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Unfocus any text fields when tapping outside
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        title: 'Hushh Agent App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: CustomColors.primary,
          scaffoldBackgroundColor: Colors.white,
        ),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: Routes.generateRoute,
      ),
    );
  }
}

