import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../shared/constants/app_routes.dart';
import '../../../agent_profile/presentation/components/luxury_identity_card.dart';

class AuthCardCreatedPage extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const AuthCardCreatedPage({
    super.key,
    required this.profileData,
  });

  @override
  State<AuthCardCreatedPage> createState() => _AuthCardCreatedPageState();
}

class _AuthCardCreatedPageState extends State<AuthCardCreatedPage>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _cardController;
  late Animation<double> _cardScaleAnimation;
  late Animation<double> _cardOpacityAnimation;
  bool _isCreatingProfile = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _createAgentProfile();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _cardScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    ));

    _cardOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));
  }

  Future<void> _createAgentProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create or update agent profile in Firestore
      await FirebaseFirestore.instance
          .collection('Hushhagents')
          .doc(user.uid)
          .set({
        'agentId': user.uid, // Link Firebase Auth UID
        'email': widget.profileData['email'],
        'name': widget.profileData['name'],
        'fullName': widget.profileData['name'],
        'categories': widget.profileData['categories'] ?? [],
        'brand': widget.profileData['brand'],
        'brandName': widget.profileData['brandName'],
        'isProfileComplete': true,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Simulate profile creation delay
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isCreatingProfile = false;
      });

      // Start animations
      _cardController.forward();
      _confettiController.forward();
    } catch (e) {
      print('Error creating agent profile: $e');
      setState(() {
        _isCreatingProfile = false;
      });
      _cardController.forward();
      _confettiController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCreatingProfile) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6725F2)),
              ),
              const SizedBox(height: 24),
              Text(
                'Setting up your agent profile...',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6725F2), Color(0xFFE51A5E)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6725F2).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.celebration,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '🎉 Congratulations! 🎉',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your agent profile has been created successfully',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Agent Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _cardController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _cardScaleAnimation.value,
                        child: Opacity(
                          opacity: _cardOpacityAnimation.value,
                          child: ResponsiveLuxuryCard(
                            name: widget.profileData['name'] ?? 'Agent Name',
                            designation: widget.profileData['brandName'] ??
                                'Brand Representative',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Continue Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFA342FF),
                        Color(0xFFE54D60),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA342FF).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
