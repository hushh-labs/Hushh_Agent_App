import 'package:flutter/material.dart';
import '../../../../../shared/constants/app_routes.dart';

class AgentProfileNamePage extends StatefulWidget {
  final String email;

  const AgentProfileNamePage({
    super.key,
    required this.email,
  });

  @override
  State<AgentProfileNamePage> createState() => _AgentProfileNamePageState();
}

class _AgentProfileNamePageState extends State<AgentProfileNamePage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool _isNameValid = false;
  double _nameProgress = 0.0;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateName);
    
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
    _nameController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _validateName() {
    final name = _nameController.text.trim();
    final progress = _calculateNameProgress(name);
    final isValid = name.isNotEmpty && name.length >= 2;
    
    if (isValid != _isNameValid || progress != _nameProgress) {
      setState(() {
        _isNameValid = isValid;
        _nameProgress = progress;
      });
      
      // Animate progress bar
      _progressAnimationController.animateTo(_nameProgress);
    }
  }

  /// Calculate name completion progress based on various criteria
  double _calculateNameProgress(String name) {
    if (name.isEmpty) return 0.0;
    
    double progress = 0.0;
    
    // Basic length check (40% progress)
    if (name.length >= 1) progress += 0.4;
    
    // Minimum valid length (30% progress)
    if (name.length >= 2) progress += 0.3;
    
    // Good length (20% progress)
    if (name.length >= 3) progress += 0.2;
    
    // No numbers or special characters (10% progress)
    if (!RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]').hasMatch(name)) {
      progress += 0.1;
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
                '50%',
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
                value: 0.50,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6725F2)),
                minHeight: 10,
              ),
            ),

            const SizedBox(height: 26),

            // Title
            const Text(
              "What's your name?",
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
                "This will be visible on your profile",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Name input form
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
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your full name',
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
                              Icons.person_outline,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          if (value.trim().length < 2) {
                            return 'Name should be at least 2 characters';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _validateName();
                          setState(() {});
                        },
                        textInputAction: TextInputAction.done,
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
                          colors: _getProgressGradientColors(_nameProgress),
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
                      onPressed: _isNameValid
                          ? () {
                              if (_formKey.currentState?.validate() ?? false) {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.agentProfileCategories,
                                  arguments: {
                                    'email': widget.email,
                                    'name': _nameController.text.trim(),
                                  },
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
                          if (_isNameValid) ...[
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