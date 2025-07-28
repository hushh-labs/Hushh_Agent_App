import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/enum.dart';

import '../bloc/auth_bloc.dart';
import '../../di/auth_injection.dart';
import 'auth.dart';

class MainAuthSelectionPage extends StatelessWidget {
  const MainAuthSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE54D60), // Pink/Red
              Color(0xFFA342FF), // Purple
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Hushh Agent Logo/Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      'S',
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // App Title
                const Text(
                  'Hushh Agent',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                const Text(
                  'Unlock the power of your data',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(flex: 3),
                // Authentication Options
                Column(
                  children: [
                    _buildAuthButton(
                      context,
                      'Continue With Phone',
                      Icons.phone,
                      () => _navigateToAuth(context, LoginMode.phone),
                    ),
                    const SizedBox(height: 14),
                    _buildAuthButton(
                      context,
                      'Continue With Email',
                      Icons.email,
                      () => _navigateToAuth(context, LoginMode.email),
                    ),
                    const SizedBox(height: 14),
                    _buildAuthButton(
                      context,
                      'Continue With Guest',
                      Icons.person,
                      () => _navigateToGuest(context),
                    ),
                  ],
                ),
                const Spacer(flex: 1),
                // Terms of Service
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    children: [
                      const TextSpan(text: 'By entering information, I agree to Hushh\'s '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                        ),
                      ),
                      const TextSpan(text: ', '),
                      TextSpan(
                        text: 'Non-discrimination Policy',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Payments Terms of Service',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                        ),
                      ),
                      const TextSpan(text: ' and acknowledge the '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildAuthButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.black),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAuth(BuildContext context, LoginMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<AuthBloc>(),
          child: AuthPage(loginMode: mode),
        ),
      ),
    );
  }

  void _navigateToGuest(BuildContext context) {
    // Guest authentication - continue without login
    // This allows users to use the app without creating an account
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Continue as Guest'),
          content: const Text(
            'You can use the app as a guest, but some features may be limited. You can create an account later to access all features.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to dashboard in guest mode
                // For now, show a success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Welcome, Guest! Enjoy exploring the app.'),
                    backgroundColor: Colors.green,
                  ),
                );
                // TODO: Navigate to dashboard when implemented
                // Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }
} 