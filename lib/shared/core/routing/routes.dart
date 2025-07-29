
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/features/auth/di/auth_injection.dart' as auth_di;
import '../../../app/features/auth/presentation/bloc/auth_bloc.dart';
import '../../../app/features/auth/presentation/pages/main_auth_selection.dart';
import '../../../app/features/auth/presentation/pages/otp_verification.dart';
import '../../../app/features/auth/domain/enum.dart';
import '../../../app/features/splash/domain/dependency/splash_injection.dart' as splash_di;
import '../../../app/features/splash/presentation/bloc/splash_bloc.dart';
import '../../../app/features/splash/presentation/pages/splash_page_with_bloc.dart';
import '../../../app/Home/di/home_injection.dart' as home_di;
import '../../../app/Home/presentation/bloc/home_bloc.dart';
import '../../../app/Home/presentation/pages/home_page.dart';
import '../../../app/features/profile_completion/presentation/pages/complete_profile_email_page.dart';
import '../../../app/features/profile_completion/presentation/pages/complete_profile_name_page.dart';
import '../../constants/app_routes.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => splash_di.sl<SplashBloc>(),
            child: const SplashPageWithBloc(),
          ),
        );

      case AppRoutes.mainAuth:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => auth_di.sl<AuthBloc>(),
            child: const MainAuthSelectionPage(),
          ),
        );

      case AppRoutes.emailVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => auth_di.sl<AuthBloc>(),
            child: OtpVerificationPage(
              args: OtpVerificationPageArgs(
                emailOrPhone: args?['email'] ?? '',
                type: args?['isPhoneFlow'] == true 
                    ? OtpVerificationType.phone 
                    : OtpVerificationType.email,
              ),
            ),
          ),
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => home_di.sl<HomeBloc>(),
            child: const HomePage(),
          ),
        );

      case AppRoutes.completeProfileEmail:
        return MaterialPageRoute(
          builder: (_) => const CompleteProfileEmailPage(),
        );

      case AppRoutes.completeProfileName:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => CompleteProfileNamePage(email: email),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }
}