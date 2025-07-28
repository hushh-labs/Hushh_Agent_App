import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import dependency injection modules
import 'app/features/splash/domain/dependency/splash_injection.dart';
import 'app/features/auth/di/auth_injection.dart';
import 'app/Home/di/home_injection.dart';

// Import routing
import 'shared/core/routing/routes.dart';

// Import theme and colors
import 'shared/constants/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }
  
  // Initialize dependency injection modules
  await _initializeDependencies();
  
  runApp(const HushhAgentApp());
}

/// Initialize all feature dependencies
Future<void> _initializeDependencies() async {
  try {
    // Initialize feature modules
    initializeSplashFeature();
    initializeAuthFeature(); 
    await initializeHomeFeature(); // Await async home feature initialization
    
    print('✅ All dependencies initialized successfully');
  } catch (e) {
    print('❌ Dependency initialization failed: $e');
    rethrow;
  }
}

class HushhAgentApp extends StatelessWidget {
  const HushhAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hushh Agent',
      
      // App Theme Configuration
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CustomColors.primary,
          brightness: Brightness.light,
        ),
        
        // App Bar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: CustomColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        
        // Button Themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        
        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: CustomColors.primary, width: 2),
          ),
        ),
      ),
      
      // Dark Theme Configuration
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CustomColors.primary,
          brightness: Brightness.dark,
        ),
      ),
      
      // Routing Configuration
      routes: NavigationManager.routes,
      initialRoute: AppRoutes.initial,
    );
  }
}

