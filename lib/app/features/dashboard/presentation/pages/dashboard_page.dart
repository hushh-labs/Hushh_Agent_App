import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../shared/core/routing/routes.dart';
import '../../../../../shared/constants/app_routes.dart';
import '../bloc/dashboard_bloc.dart' as dashboard;
import '../components/dashboard_header.dart';
import '../components/quick_insights_grid.dart';
import '../components/dashboard_tab_bar.dart';
import '../components/dashboard_content.dart';
import '../components/dashboard_floating_button.dart';
import '../components/complete_profile_section.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => dashboard.DashboardBloc()..add(const dashboard.LoadDashboardEvent()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: BlocConsumer<dashboard.DashboardBloc, dashboard.DashboardState>(
          listener: (context, state) {
            if (state is dashboard.DashboardErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is dashboard.ProfileCompletingState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Redirecting to profile completion...'),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is dashboard.DashboardLoadingState) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Default values
            double walletBalance = 0.0;
            bool isProfileComplete = false;
            List<dashboard.QuickInsightItem> insights = [];
            dashboard.DashboardTab selectedTab = dashboard.DashboardTab.services;
            List<dashboard.ServiceItem> services = [];
            List<dashboard.CustomerItem> customers = [];

            if (state is dashboard.DashboardLoadedState) {
              walletBalance = state.walletBalance;
              isProfileComplete = state.isProfileComplete;
              insights = state.insights;
              selectedTab = state.selectedTab;
              services = state.services;
              customers = state.customers;
            }

            return Column(
              children: [
                // Header with balance and notification
                DashboardHeader(
                  balance: walletBalance,
                  onNotificationTap: () => _showNotifications(context),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Complete Profile Section (replaces agent card)
                        if (!isProfileComplete)
                          CompleteProfileSection(
                            onCompleteProfile: () => _completeProfile(context),
                          ),

                        const SizedBox(height: 24),

                        // Quick Insights Grid
                        QuickInsightsGrid(insights: insights),

                        const SizedBox(height: 32),

                        // Tab Bar
                        DashboardTabBar(
                          selectedTab: selectedTab,
                          onTabSelected: (tab) => _selectTab(context, tab),
                          onRefresh: () => _refreshDashboard(context),
                        ),

                        const SizedBox(height: 16),

                        // Content based on selected tab
                        DashboardContent(
                          selectedTab: selectedTab,
                          services: services,
                          customers: customers,
                        ),

                        const SizedBox(height: 100), // Bottom padding for FAB
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: DashboardFloatingButton(
        onPressed: () => _launchQRScanner(context),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _completeProfile(BuildContext context) {
    // Navigate to profile completion flow
    Navigator.pushNamed(context, AppRoutes.completeProfileEmail);
  }

  void _selectTab(BuildContext context, dashboard.DashboardTab tab) {
    context.read<dashboard.DashboardBloc>().add(dashboard.SelectTabEvent(tab));
  }

  void _refreshDashboard(BuildContext context) {
    context.read<dashboard.DashboardBloc>().add(const dashboard.RefreshDashboardEvent());
  }

  void _launchQRScanner(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Scanner feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _addService(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Service feature coming soon!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addCustomer(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Customer feature coming soon!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _scheduleMeeting(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Schedule Meeting feature coming soon!'),
        backgroundColor: Colors.green,
      ),
    );
  }
} 