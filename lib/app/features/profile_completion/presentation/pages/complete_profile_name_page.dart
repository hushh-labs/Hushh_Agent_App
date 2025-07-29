import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../shared/core/routing/routes.dart';
import '../../../../../shared/constants/app_routes.dart';
import '../bloc/profile_completion_bloc.dart';

class CompleteProfileNamePage extends StatelessWidget {
  final String email;

  const CompleteProfileNamePage({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCompletionBloc(),
      child: _CompleteProfileNameView(email: email),
    );
  }
}

class _CompleteProfileNameView extends StatefulWidget {
  final String email;

  const _CompleteProfileNameView({required this.email});

  @override
  State<_CompleteProfileNameView> createState() => _CompleteProfileNameViewState();
}

class _CompleteProfileNameViewState extends State<_CompleteProfileNameView> {
  final TextEditingController _nameController = TextEditingController();
  bool _isNameValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _validateName() {
    final name = _nameController.text.trim();
    final isValid = name.isNotEmpty && name.length >= 2;
    if (isValid != _isNameValid) {
      setState(() {
        _isNameValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Complete profile',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      body: BlocConsumer<ProfileCompletionBloc, ProfileCompletionState>(
        listener: (context, state) {
          if (state is ProfileCompletionCompletedState) {
            // Navigate back to dashboard and refresh
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile completed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProfileCompletionErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Progress Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '0%',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6A4CFF)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'What\'s your name?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Name Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter your name',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name Tag Display
                    if (_nameController.text.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _nameController.text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  _nameController.clear();
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const Spacer(),

              // Continue Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isNameValid
                        ? () {
                            context.read<ProfileCompletionBloc>().add(
                              CompleteProfileEvent(
                                email: widget.email,
                                name: _nameController.text.trim(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isNameValid
                          ? null
                          : Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ).copyWith(
                      backgroundColor: _isNameValid
                          ? WidgetStateProperty.resolveWith<Color>((states) {
                              return const Color(0xFF6A4CFF);
                            })
                          : WidgetStateProperty.all(Colors.grey.shade300),
                    ),
                    child: state is ProfileCompletionLoadingState
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 