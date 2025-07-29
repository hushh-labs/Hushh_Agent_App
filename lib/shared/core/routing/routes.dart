
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../constants/app_routes.dart';
import '../../../app/features/splash/presentation/bloc/splash_bloc.dart';
import '../../../app/features/splash/presentation/pages/splash_page_with_bloc.dart';
import '../../../app/features/auth/presentation/bloc/auth_bloc.dart';
import '../../../app/features/auth/presentation/pages/main_auth_selection.dart';
import '../../../app/features/auth/presentation/pages/otp_verification.dart';
import '../../../app/features/auth/domain/enum.dart';
import '../../../app/Home/presentation/bloc/home_bloc.dart';
import '../../../app/Home/presentation/pages/home_page.dart';

import '../../../app/features/lookbooks_products/presentation/bloc/lookbook_bloc.dart';
import '../../../app/features/lookbooks_products/presentation/pages/agent_lookbook_page.dart';
import '../../../app/features/agent_profile/presentation/pages/agent_profile_email_page.dart';
import '../../../app/features/agent_profile/presentation/pages/agent_profile_name_page.dart';
import '../../../app/features/agent_profile/presentation/pages/agent_profile_categories_page.dart';
import '../../../app/features/agent_profile/presentation/pages/agent_profile_brands_page.dart';
import '../../../app/features/agent_profile/presentation/pages/agent_card_created_page.dart';

final sl = GetIt.instance;

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<SplashBloc>(),
            child: const SplashPageWithBloc(),
          ),
        );

      case AppRoutes.mainAuth:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<AuthBloc>(),
            child: const MainAuthSelectionPage(),
          ),
        );

      case AppRoutes.emailVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<AuthBloc>(),
            child: OtpVerificationPage(
              args: OtpVerificationPageArgs(
                emailOrPhone: args?['emailOrPhone'] ?? '',
                type: args?['type'] ?? OtpVerificationType.phone,
              ),
            ),
          ),
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<HomeBloc>(),
            child: const HomePage(),
          ),
        );



      case AppRoutes.agentProfileEmail:
        return MaterialPageRoute(
          builder: (_) => const AgentProfileEmailPage(),
        );

      case AppRoutes.agentProfileName:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => AgentProfileNamePage(email: email),
        );

      case AppRoutes.agentProfileCategories:
        final profileData = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => AgentProfileCategoriesPage(profileData: profileData),
        );

      case AppRoutes.agentProfileBrands:
        final profileData = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => AgentProfileBrandsPage(profileData: profileData),
        );

      case AppRoutes.agentCardCreated:
        final profileData = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (_) => AgentCardCreatedPage(profileData: profileData),
        );

      case AppRoutes.agentLookbook:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<LookbookBloc>(),
            child: const AgentLookBookPage(),
          ),
        );

      case AppRoutes.createLookbook:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<LookbookBloc>(),
            child: const CreateLookbookPage(),
          ),
        );

      case AppRoutes.agentProducts:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<LookbookBloc>(),
            child: AgentProductsPage(
              lookbookId: args?['lookbookId'],
              mode: args?['mode'] ?? 'view',
            ),
          ),
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

// Placeholder pages that need to be implemented
class CreateLookbookPage extends StatelessWidget {
  const CreateLookbookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Lookbook'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          'Create Lookbook Page\n(To be implemented)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class AgentProductsPage extends StatelessWidget {
  final String? lookbookId;
  final String mode;

  const AgentProductsPage({
    super.key,
    this.lookbookId,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lookbookId != null ? 'Lookbook Products' : 'All Products'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lookbookId != null 
                  ? 'Lookbook Products Page\n(Lookbook ID: $lookbookId)'
                  : 'All Products Page',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              '(To be implemented)',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}