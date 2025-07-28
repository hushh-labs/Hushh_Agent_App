import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import '../../domain/entities/home_section.dart';
import '../../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../../features/chat/presentation/pages/chat_page.dart';
import '../../../features/profile/presentation/pages/profile_page.dart';
import '../../../features/reports/presentation/pages/reports_page.dart';
import '../../../../shared/constants/colors.dart';
import '../../../../shared/core/routing/routes.dart';

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
        if (state is HomeLoadingState) {
          return Scaffold(
            backgroundColor: CustomColors.primary,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hushh Logo or App Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.business,
                      size: 40,
                      color: CustomColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading your business dashboard...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

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
                DashboardPage(),
                ChatPage(),
                ProfilePage(),
                ReportsPage(),
              ],
            ),
            bottomNavigationBar: _buildBottomNavigationBar(state),
          );
        }

        // Initial state - show loading
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
                    Icons.business,
                    size: 40,
                    color: CustomColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Initializing Hushh Agent...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(HomeLoadedState state) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: state.currentTabIndex,
        onTap: (index) {
          context.read<HomeBloc>().add(NavigateToTabEvent(index));
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: CustomColors.primary,
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: state.sections.map((section) {
          return BottomNavigationBarItem(
            icon: _buildSectionIcon(section, false),
            activeIcon: _buildSectionIcon(section, true),
            label: section.title,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionIcon(HomeSection section, bool isActive) {
    IconData iconData;
    
    switch (section.id) {
      case 'dashboard':
        iconData = Icons.dashboard_outlined;
        break;
      case 'chat':
        iconData = Icons.chat_bubble_outline;
        break;
      case 'profile':
        iconData = Icons.person_outline;
        break;
      case 'reports':
        iconData = Icons.analytics_outlined;
        break;
      default:
        iconData = Icons.apps;
    }

    if (isActive) {
      switch (section.id) {
        case 'dashboard':
          iconData = Icons.dashboard;
          break;
        case 'chat':
          iconData = Icons.chat_bubble;
          break;
        case 'profile':
          iconData = Icons.person;
          break;
        case 'reports':
          iconData = Icons.analytics;
          break;
        default:
          iconData = Icons.apps;
      }
    }

    Widget iconWidget = Icon(iconData);

    // Add notification badge if needed
    if (section.notificationCount != null && section.notificationCount! > 0) {
      iconWidget = Stack(
        children: [
          iconWidget,
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                section.notificationCount! > 99 
                    ? '99+' 
                    : section.notificationCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    return iconWidget;
  }
} 