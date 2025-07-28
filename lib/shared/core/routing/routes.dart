
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/features/splash/presentation/pages/splash_page_with_bloc.dart';
import '../../../app/features/splash/presentation/bloc/splash_bloc.dart';
import '../../../app/features/splash/domain/dependency/splash_injection.dart';
import '../../../app/features/auth/presentation/pages/main_auth_selection.dart';
import '../../../app/features/auth/presentation/pages/otp_verification.dart';
import '../../../app/features/auth/domain/enum.dart';
import '../../../app/Home/presentation/pages/home_page.dart';
import '../../../app/Home/presentation/bloc/home_bloc.dart';
import '../../../app/Home/di/home_injection.dart' as home_di;
import '../../../app/features/auth/di/auth_injection.dart' as auth_di;
import '../../../app/features/auth/presentation/bloc/auth_bloc.dart';

class AppRoutes {
    
    // Initial routes
    static const String initial = '/';
    static const String splash = '/splash';

    // Auth routes
    static const String mainAuth = '/mainAuth';
    static const String otpVerification = '/otpVerification';
    
    // Home routes
    static const String home = '/home';
}

class NavigationManager {
       static final Map<String, WidgetBuilder> routes = {
              AppRoutes.initial: (context) => BlocProvider(
                create: (context) => sl<SplashBloc>(),
                child: const SplashPageWithBloc(),
              ),
              AppRoutes.splash: (context) => BlocProvider(
                create: (context) => sl<SplashBloc>(),
                child: const SplashPageWithBloc(),
              ),

              AppRoutes.mainAuth: (context) => const MainAuthSelectionPage(),
              AppRoutes.otpVerification: (context) => BlocProvider(
                create: (context) => auth_di.sl<AuthBloc>(),
                child: OtpVerificationPage(
                  args: OtpVerificationPageArgs(
                    emailOrPhone: '',
                    type: OtpVerificationType.phone,
                  ),
                ),
              ),
              AppRoutes.home: (context) => BlocProvider(
                create: (context) => home_di.sl<HomeBloc>(),
                child: const HomePage(),
              ),
       };
}