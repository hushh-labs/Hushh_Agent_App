import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../../domain/entities/home_section.dart';
import '../../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../../features/chat/presentation/pages/chat_page.dart';
import '../../../features/profile/presentation/pages/profile_page.dart';

import '../../../../shared/constants/colors.dart';
import '../../../../shared/core/routing/routes.dart';
import '../../../../shared/presentation/widgets/google_style_bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Initialize home when the page loads
    context.read<HomeBloc>().add(const InitializeHomeEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        // Handle authentication state changes for routing
        if (state is HomeAuthenticationRequiredState) {
          // Navigate to authentication page
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.mainAuth,
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        if (state is HomeAuthenticationRequiredState) {
          return Scaffold(
            backgroundColor: CustomColors.primary,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 40,
                      color: CustomColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Authentication Required',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message ?? 'Please log in to continue',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.mainAuth,
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: CustomColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is HomeErrorState) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read<HomeBloc>().add(const InitializeHomeEvent());
                        },
                        child: const Text('Retry'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<HomeBloc>().add(LogoutEvent());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        if (state is HomeLoadedState) {
          return Scaffold(
            body: IndexedStack(
              index: state.currentTabIndex,
              children: const [
                ChatPage(),
                DashboardPage(),
                ProfilePage(),
              ],
            ),
            bottomNavigationBar: _buildBottomNavigationBar(state),
          );
        }

        // Initial state - minimal loading (authentication check happens instantly)
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: SizedBox.shrink(), // Minimal loading - authentication check is instant
          ),
        );
      },
    );
  }

  /// Enhanced Bottom Navigation Bar with Complete Animation System
  Widget _buildBottomNavigationBar(HomeLoadedState state) {
    return GoogleStyleBottomNav(
      currentIndex: state.currentTabIndex,
      onTap: (index) {
        context.read<HomeBloc>().add(NavigateToTabEvent(index));
      },
      isAgentApp: true,
      items: _buildBottomNavItems(state.sections),
    );
  }

  /// Convert HomeSection objects to BottomNavItem objects
  List<BottomNavItem> _buildBottomNavItems(List<HomeSection> sections) {
    return sections.map((section) {
      return BottomNavItem.agent(
        label: section.title,
        icon: _getIconForSection(section.id),
        iconPath: _getSvgPathForSection(section.id), // For SVG icons if you have them
        isRestrictedForGuest: _isRestrictedSection(section.id),
      );
    }).toList();
  }

  /// Get Material icon for each section
  IconData _getIconForSection(String sectionId) {
    switch (sectionId) {
      case 'chat':
        return Icons.message; // More visible chat icon
      case 'dashboard':
        return Icons.dashboard;
      case 'profile':
        return Icons.person;
      default:
        return Icons.apps;
    }
  }

  /// Get SVG icon path for each section (if you have SVG assets)
  String? _getSvgPathForSection(String sectionId) {
    switch (sectionId) {
      case 'chat':
        return null; // Will fallback to Material icon
      case 'dashboard':
        return null; // Will fallback to Material icon  
      case 'profile':
        return null; // Will fallback to Material icon
      default:
        return null;
    }
  }

  /// Define which sections are restricted for guest users
  bool _isRestrictedSection(String sectionId) {
    switch (sectionId) {
      case 'chat':
        return true; // Chat requires authentication
      case 'dashboard':
        return true; // Dashboard requires authentication
      case 'profile':
        return true; // Profile requires authentication
      default:
        return false;
    }
  }
} 