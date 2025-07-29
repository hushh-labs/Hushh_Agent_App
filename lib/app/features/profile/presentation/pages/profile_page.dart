import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../shared/constants/app_routes.dart';
import '../../../auth/di/auth_injection.dart' as auth_di;
import '../../../auth/presentation/bloc/auth_bloc.dart' as auth;
import '../bloc/profile_bloc.dart' as profile;
import '../components/profile_header.dart';
import '../components/profile_menu_section.dart';
import '../components/profile_menu_item.dart';
import '../components/profile_dialogs.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => profile.ProfileBloc()..add(const profile.LoadProfileEvent()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocConsumer<profile.ProfileBloc, profile.ProfileState>(
        listener: (context, state) {
          if (state is profile.ProfileErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is profile.ProfileUpdatedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is profile.FeedbackSentState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thank you for your feedback!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is profile.AccountDeletedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account deletion requested. We\'ll process this shortly.'),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is profile.SignedOutState) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.mainAuth,
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is profile.ProfileLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          String displayName = 'Update your name';
          String email = 'Add email';
          String? avatarUrl;

          if (state is profile.ProfileLoadedState) {
            displayName = state.displayName;
            email = state.email;
            avatarUrl = state.avatarUrl;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                ProfileHeader(
                  displayName: displayName,
                  email: email,
                  avatarUrl: avatarUrl,
                  onEditTap: () => _editProfile(context),
                ),
                
                const SizedBox(height: 24),
                
                // Manage Section
                ProfileMenuSection(
                  title: 'Manage',
                  items: [
                    ProfileMenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      iconColor: const Color(0xFFA342FF),
                      onTap: () => ProfileDialogs.showComingSoon(context),
                    ),
                    ProfileMenuItem(
                      icon: Icons.security,
                      title: 'Permissions',
                      iconColor: const Color(0xFFA342FF),
                      onTap: () => ProfileDialogs.showComingSoon(context),
                    ),
                    ProfileMenuItem(
                      icon: Icons.wallet,
                      title: 'Wallet & Cards',
                      iconColor: const Color(0xFFA342FF),
                      onTap: () => ProfileDialogs.showComingSoon(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // More Section
                ProfileMenuSection(
                  title: 'More',
                  items: [
                    ProfileMenuItem(
                      icon: Icons.feedback_outlined,
                      title: 'Send Feedback',
                      iconColor: const Color(0xFFA342FF),
                      onTap: () => _sendFeedback(context),
                    ),
                    ProfileMenuItem(
                      icon: Icons.delete_outline,
                      title: 'Delete Account',
                      iconColor: const Color(0xFFA342FF),
                      onTap: () => _deleteAccount(context),
                    ),
                    ProfileMenuItem(
                      icon: Icons.logout,
                      title: 'Logout',
                      iconColor: const Color(0xFFA342FF),
                      showArrow: false,
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // App Version
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Version 1.0.1 ✨ Build 74',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 100), // Bottom padding for navigation
              ],
            ),
          );
        },
      ),
    );
  }

  void _editProfile(BuildContext context) {
    // TODO: Navigate to edit profile page
    ProfileDialogs.showComingSoon(context);
  }

  void _sendFeedback(BuildContext context) {
    ProfileDialogs.showFeedbackDialog(context, (feedback) {
      context.read<profile.ProfileBloc>().add(profile.SendFeedbackEvent(feedback));
    });
  }

  void _deleteAccount(BuildContext context) {
    ProfileDialogs.showDeleteAccountDialog(context, () {
      context.read<profile.ProfileBloc>().add(const profile.DeleteAccountEvent());
    });
  }

  void _logout(BuildContext context) {
    ProfileDialogs.showLogoutDialog(context, () {
      // Create AuthBloc and trigger logout
      final authBloc = auth_di.sl<auth.AuthBloc>();
      authBloc.add(auth.SignOutEvent());
      
      // Also trigger ProfileBloc logout
      context.read<profile.ProfileBloc>().add(const profile.SignOutEvent());
    });
  }
} 