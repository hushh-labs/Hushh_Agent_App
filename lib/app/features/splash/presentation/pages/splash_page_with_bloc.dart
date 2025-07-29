import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';
import '../../../../../shared/constants/app_routes.dart';

/// Splash screen with complete Clean Architecture and BLoC implementation
/// Now leverages HomeBloc for routing decisions
class SplashPageWithBloc extends StatefulWidget {
  const SplashPageWithBloc({Key? key}) : super(key: key);

  @override
  State<SplashPageWithBloc> createState() => _SplashPageWithBlocState();
}

class _SplashPageWithBlocState extends State<SplashPageWithBloc>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _animationCompleted = false;
  bool _initializationCompleted = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Listen for animation completion
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_animationCompleted) {
        _animationCompleted = true;
        // Check if we can proceed with routing
        _checkForRouting();
      }
    });

    // Start initialization and animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplashBloc>().add(const SplashInitializeEvent());
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<SplashBloc, SplashState>(
        listener: (context, state) {
          _handleStateChanges(context, state);
        },
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
    );
  }

  /// Handle state changes for navigation and side effects
  void _handleStateChanges(BuildContext context, SplashState state) {
    if (state is SplashInitializationCompleteState || 
        state is SplashNoAgentState || 
        state is SplashInitializationErrorState) {
      _initializationCompleted = true;
      _checkForRouting();
    }
  }

  /// Check if both animation and initialization are complete, then route
  void _checkForRouting() {
    if (_animationCompleted && _initializationCompleted && mounted) {
      _routeBasedOnAuthentication();
    }
  }

  /// Route based on authentication status using HomeBloc logic
  void _routeBasedOnAuthentication() {
    // Add slight delay for smooth UX
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      // Check Firebase Auth state directly
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        // User is authenticated, navigate to home
        debugPrint('🏠 → User authenticated, navigating to Home Dashboard');
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      } else {
        // User not authenticated, navigate to auth
        debugPrint('🔐 → User not authenticated, navigating to Authentication');
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.mainAuth,
          (route) => false,
        );
      }
    });
  }

  /// Build the UI based on current state
  Widget _buildBody(BuildContext context, SplashState state) {
    return Stack(
      children: [
        // Main content - Lottie animation
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!kIsWeb)
                Transform.scale(
                  scale: 1.5,
                  child: Lottie.asset(
                    'assets/splash-anim.json',
                    repeat: false,
                    controller: _animationController,
                  ),
                )
              else
                Image.asset('assets/splash.gif'),
            ],
          ),
        ),

        // Loading indicator and status message (bottom overlay)
        if (_shouldShowLoadingIndicator(state))
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: _buildLoadingIndicator(state),
          ),

        // Error handling overlay
        if (state is SplashInitializationErrorState)
          _buildErrorOverlay(context, state),
      ],
    );
  }

  /// Check if we should show loading indicator
  bool _shouldShowLoadingIndicator(SplashState state) {
    return state is SplashInitializingState ||
           state is SplashCheckingAuthState ||
           state is SplashLoadingProfileState ||
           state is SplashSetupNotificationsState ||
           state is SplashCheckingPermissionsState ||
           state is SplashInitializingAnalyticsState ||
           state is SplashLoadingBusinessDataState;
  }

  /// Build loading indicator with progress and message
  Widget _buildLoadingIndicator(SplashState state) {
    String message = 'Initializing Hushh Agent...';
    double progress = 0.0;

    if (state is SplashInitializingState) {
      message = state.message;
      progress = state.progress;
    } else if (state is SplashCheckingAuthState) {
      message = 'Checking authentication...';
      progress = 0.3;
    } else if (state is SplashLoadingProfileState) {
      message = 'Loading agent profile...';
      progress = 0.6;
    } else if (state is SplashSetupNotificationsState) {
      message = 'Setting up notifications...';
      progress = 0.8;
    }

    return Column(
      children: [
        // Progress indicator
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF6366F1), // Indigo color
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Status message
        Text(
          message,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build error overlay with retry option
  Widget _buildErrorOverlay(BuildContext context, SplashInitializationErrorState state) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Initialization Failed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                state.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (state.canRetry)
                    ElevatedButton(
                      onPressed: () {
                        context.read<SplashBloc>().add(
                          const SplashRetryInitializationEvent(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      // Force navigate to auth on error
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.mainAuth,
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 