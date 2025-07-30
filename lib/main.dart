import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'shared/constants/app_routes.dart';
import 'shared/constants/colors.dart';
import 'shared/config/theme/text_theme.dart';
import 'shared/core/routing/routes.dart';
import 'app/features/auth/di/auth_injection.dart' as auth_di;
import 'app/features/splash/domain/dependency/splash_injection.dart'
    as splash_di;
import 'app/Home/di/home_injection.dart' as home_di;

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hushh Agent App',
      debugShowCheckedModeBanner: false,
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
