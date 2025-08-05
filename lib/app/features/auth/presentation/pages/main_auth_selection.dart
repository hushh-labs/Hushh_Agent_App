import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth.dart';
import '../../domain/enum.dart';
import '../../../../../shared/core/utils/screen_utils.dart';
import '../../../../../shared/constants/app_routes.dart';
import '../../di/auth_injection.dart' as auth_di;
import '../bloc/auth_bloc.dart';

class MainAuthSelectionPage extends StatefulWidget {
  const MainAuthSelectionPage({super.key});

  @override
  State<MainAuthSelectionPage> createState() => _MainAuthSelectionPageState();
}

class _MainAuthSelectionPageState extends State<MainAuthSelectionPage> {
  final List<Map<String, dynamic>> socialMethods = [
    {
      'type': 'Phone',
      'icon': Icons.phone,
      'text': 'Continue with Phone',
    },
    // {
    //   'type': 'Email',
    //   'icon': Icons.email,
    //   'text': 'Continue with Email',
    // },
    {
      'type': 'Guest',
      'icon': Icons.person_outline,
      'text': 'Continue as Guest'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        height: context.heightPercent(75),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [Color(0xFFE54D60), Color(0xFFA342FF)],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          50), // Adjust value for roundness
                                      child: Image.asset(
                                        'assets/hushh_s_logo_v1.png',
                                        width: context.widthPercent(33),
                                        height: context.widthPercent(33) * 1.2,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Hushh Agent 🤫',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            letterSpacing: -1,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Unlock the power of your data',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Column(
                                children: List.generate(
                                  socialMethods.length,
                                  (index) => SocialButton(
                                    text: socialMethods[index]['text']!,
                                    icon: socialMethods[index]['icon']!,
                                    onTap: () {
                                      // Handle button tap based on type
                                      if (socialMethods[index]['type'] ==
                                          'Phone') {
                                        _navigateToAuth(
                                            context, LoginMode.phone);
                                      } else if (socialMethods[index]['type'] ==
                                          'Email') {
                                        // Show coming soon message for email
                                        _showComingSoonMessage(
                                            context, 'Continue with Email');
                                      } else if (socialMethods[index]['type'] ==
                                          'Guest') {
                                        // Handle guest login
                                        _navigateToGuest(context);
                                      }
                                    },
                                  )
                                      .animate(delay: (300 * index).ms)
                                      .fade(duration: 700.ms)
                                      .moveX(duration: 800.ms),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Legal text at the bottom with minimal spacing
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 2.0,
              ),
              child: GestureDetector(
                onTap: () async {
                  final Uri url = Uri.parse('https://hushh.ai');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text.rich(
                  TextSpan(
                    text: "By entering information, I agree to Hushh's ",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.black.withValues(alpha: 0.7),
                        ),
                    children: <InlineSpan>[
                      const TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(color: Color(0xFFE54D60)),
                      ),
                      const TextSpan(text: ', '),
                      const TextSpan(
                        text: 'Non-discrimination Policy',
                        style: TextStyle(color: Color(0xFFE54D60)),
                      ),
                      const TextSpan(text: ' and '),
                      const TextSpan(
                        text: 'Payments Terms of Service',
                        style: TextStyle(color: Color(0xFFE54D60)),
                      ),
                      const TextSpan(text: ' and acknowledge the '),
                      const TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(color: Color(0xFFE54D60)),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAuth(BuildContext context, LoginMode loginMode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => auth_di.sl<AuthBloc>(),
          child: AuthPage(loginMode: loginMode),
        ),
      ),
    );
  }

  void _navigateToGuest(BuildContext context) {
    // Navigate directly to home page in guest mode without popup
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  void _showComingSoonMessage(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.pink],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            '$feature is coming soon!',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const SocialButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: Colors.black87,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
