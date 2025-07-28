import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:hushh_agent_app/app/features/splash/domain/dependency/splash_injection.dart';
import 'package:hushh_agent_app/app/features/auth/di/auth_injection.dart';
import 'package:hushh_agent_app/app/Home/di/home_injection.dart';
import 'package:hushh_agent_app/shared/core/firebase/firestore_service.dart';
import 'package:hushh_agent_app/shared/core/routing/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Firestore
  await FirestoreService.initialize();
  
  // Firebase connectivity test disabled for now
  // Will be enabled after routing is fixed
  
  // Initialize dependency injection
  initializeSplashFeature();
  initializeAuthFeature();
  initializeHomeFeature();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hushh Agent App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: AppRoutes.initial,
      routes: NavigationManager.routes,
    );
  }
}

