import 'package:flutter/material.dart';
import '../../../../../shared/constants/app_routes.dart';

class AuthEmailPage extends StatefulWidget {
  const AuthEmailPage({super.key});

  @override
  State<AuthEmailPage> createState() => _AuthEmailPageState();
}

class _AuthEmailPageState extends State<AuthEmailPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isEmailValid = false;
  double _emailProgress = 0.0;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    
    // Initialize animation controller for smooth progress transitions
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressAnimationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    final progress = _calculateEmailProgress(email);
    final isValid = email.isNotEmpty &&
        email.contains('@') &&
        email.contains('.') &&
        RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
    
    if (isValid != _isEmailValid || progress != _emailProgress) {
      setState(() {
        _isEmailValid = isValid;
        _emailProgress = progress;
      });
      
      // Animate progress bar
      _progressAnimationController.animateTo(_emailProgress);
    }
  }

  /// Calculate email completion progress based on various criteria
  double _calculateEmailProgress(String email) {
    if (email.isEmpty) return 0.0;
    
    double progress = 0.0;
    
    // Basic length check (20% progress)
    if (email.length >= 3) progress += 0.2;
    
    // Contains @ symbol (30% progress)
    if (email.contains('@')) progress += 0.3;
    
    // Has content before @ (20% progress)
    if (email.contains('@') && email.indexOf('@') > 0) progress += 0.2;
    
    // Contains domain after @ (20% progress)
    if (email.contains('@') && email.indexOf('@') < email.length - 1) {
      final domain = email.split('@').last;
      if (domain.isNotEmpty) progress += 0.2;
    }
    
    // Contains valid domain with dot (10% progress)
    if (email.contains('.') && email.contains('@')) {
      final parts = email.split('@');
      if (parts.length == 2 && parts.last.contains('.')) {
        final domainParts = parts.last.split('.');
        if (domainParts.length >= 2 && domainParts.last.length >= 2) {
          progress += 0.1;
        }
      }
    }
    
    return progress.clamp(0.0, 1.0);
  }

  /// Get dynamic gradient colors based on progress
  List<Color> _getProgressGradientColors(double progress) {
    if (progress == 0.0) {
      // Start with subtle purple/pink gradients when empty (attractive disabled state)
      return [
        const Color(0xFFA342FF).withOpacity(0.3),
        const Color(0xFFE54D60).withOpacity(0.2),
      ];
    } else if (progress < 1.0) {
      // Transition from pink/purple to blue as user types
      final t = progress;
      return [
        Color.lerp(const Color(0xFFA342FF), const Color(0xFF2196F3), t)!,
        Color.lerp(const Color(0xFFE54D60), const Color(0xFF1976D2), t)!,
      ];
    } else {
      // Complete - beautiful blue gradient
      return [
        const Color(0xFF2196F3),
        const Color(0xFF1976D2),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Text(
          'Complete profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            child: const Text('BACK'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '25%',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: LinearProgressIndicator(
                value: 0.25,
                backgroundColor: Colors.grey[300],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF6725F2)),
                minHeight: 10,
              ),
            ),

            const SizedBox(height: 26),

            // Title
            const Text(
              'Enter your Email ID',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle with gradient
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFA342FF), Color(0xFFE54D60)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              child: const Text(
                "We'll use this to keep you updated",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Email input form
            Expanded(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFA342FF), Color(0xFFE54D60)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(
                            color: const Color(0xFFA342FF).withOpacity(0.4),
                            fontSize: 16,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: InputBorder.none,
                          prefixIcon: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFA342FF), Color(0xFFE54D60)],
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.email_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email address';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _validateEmail();
                          setState(() {});
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Progress indicator
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFA342FF).withOpacity(0.1),
                        const Color(0xFFE54D60).withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          colors: _getProgressGradientColors(_emailProgress),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Continue button with static gradient
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(43),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFFA342FF), Color(0xFFE54D60)],
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
                      onPressed: _isEmailValid
                          ? () {
                              if (_formKey.currentState?.validate() ?? false) {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.authName,
                                  arguments: _emailController.text.trim(),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(43),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (_isEmailValid) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
