import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hushh_agent_app/app/features/splash/presentation/pages/splash_page_with_bloc.dart';
import 'package:hushh_agent_app/app/features/splash/domain/dependency/splash_injection.dart';
import 'package:hushh_agent_app/app/features/splash/presentation/bloc/splash_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  initializeSplashFeature();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hushh Agent App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: BlocProvider(
        create: (context) => sl<SplashBloc>(),
        child: const SplashPageWithBloc(),
      ),
    );
  }
}

