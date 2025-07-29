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
  final _formKey = GlobalKey<FormState>();
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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Text(
          'Complete profile',
          style: TextStyle(
            color: const Color(0xFF797979).withOpacity(0.8),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.clear,
              color: Color(0xFF797979),
            ),
          ),
          const SizedBox(width: 8),
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
          return Padding(
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

                // Subtitle
                const Text(
                  "Let's start with your name",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    letterSpacing: 0.4,
                  ),
                ),

                const SizedBox(height: 32),

                // Name input form
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your full name',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF6725F2),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
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
                          onChanged: (value) => setState(() {}),
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                  ),
                ),

                // Continue button
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(43),
                      gradient: _isNameValid
                          ? const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFFA342FF),
                                Color(0xFFE54D60),
                              ],
                            )
                          : null,
                      color: !_isNameValid ? Colors.grey : null,
                    ),
                    child: ElevatedButton(
                      onPressed: _isNameValid
                          ? () {
                              if (_formKey.currentState?.validate() ?? false) {
                                context.read<ProfileCompletionBloc>().add(
                                  CompleteProfileEvent(
                                    email: widget.email,
                                    name: _nameController.text.trim(),
                                  ),
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
                      child: state is ProfileCompletionLoadingState
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : const Text(
                              'Complete',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
} 