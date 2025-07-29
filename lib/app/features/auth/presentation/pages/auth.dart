// app/platforms/mobile/auth/presentation/pages/auth.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../bloc/auth_bloc.dart';
import '../components/country_code_text_field.dart';
import '../components/email_text_field.dart';
import '../components/phone_number_text_field.dart';

import '../../domain/enum.dart';
import 'otp_verification.dart';

import '../../../../../shared/utils/development_helper.dart';

class AuthPage extends StatefulWidget {
  final LoginMode loginMode;

  const AuthPage({super.key, this.loginMode = LoginMode.phone});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  String _lastUsedPhoneNumber = '';
  late AuthBloc _authBloc;
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    _authBloc = context.read<AuthBloc>();
    _authBloc.add(InitializeEvent(true));
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (widget.loginMode == LoginMode.email) {
      // Send email OTP only if email is valid
      if (_isEmailValid && _emailController.text.isNotEmpty) {
        _authBloc.add(SendEmailOtpEvent(_emailController.text));
      }
    } else {
      // Send phone OTP
      final phoneDigits = _authBloc.phoneNumberWithoutCountryCode;
      final countryCode = _authBloc.selectedCountry?.dialCode ?? '91';
      final fullPhoneNumber = '+$countryCode$phoneDigits';
      
      // Store the phone number locally for navigation
      _lastUsedPhoneNumber = fullPhoneNumber;

      _authBloc.add(SendPhoneOtpEvent(fullPhoneNumber));
    }
  }

  void _navigateToOtpVerification(BuildContext context, String emailOrPhone) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider<AuthBloc>.value(
          value: _authBloc,
          child: OtpVerificationPage(
            args: OtpVerificationPageArgs(
              emailOrPhone: emailOrPhone,
              type: widget.loginMode == LoginMode.email 
                  ? OtpVerificationType.email 
                  : OtpVerificationType.phone,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpSentFailureState) {
          // Show error dialog with retry option
          _showErrorDialog(context, state.message);
        } else if (state is OtpSentState) {
          // OTP sent successfully, navigate to verification
          final emailOrPhone = widget.loginMode == LoginMode.email 
              ? _emailController.text 
              : _lastUsedPhoneNumber;
          
          // Use post frame callback to ensure navigation happens after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToOtpVerification(context, emailOrPhone);
          });
        }
      },
      child: Material(
        color: Colors.white,
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height * 0.7,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD8DADC)),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_ios_new_sharp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Log in to your account',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.loginMode == LoginMode.email
                        ? 'Welcome! Please enter your email address. We\'ll send you an OTP to verify.'
                        : 'Welcome! Please enter your phone number. We\'ll send you an OTP to verify.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                if (widget.loginMode == LoginMode.email) ...[
                  EmailTextField(
                    controller: _emailController,
                    onValidationChanged: (isValid) {
                      setState(() {
                        _isEmailValid = isValid;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isDisabled = state is SendingOtpState || !_isEmailValid;
                      
                      return InkWell(
                        onTap: isDisabled ? null : _sendOtp,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: isDisabled 
                                ? LinearGradient(
                                    colors: [Colors.grey.shade400, Colors.grey.shade500],
                                  )
                                : const LinearGradient(
                                    colors: [Color(0XFFA342FF), Color(0XFFE54D60)],
                                  ),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Center(
                            child: state is SendingOtpState
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "Continue",
                                    style: TextStyle(
                                      color: isDisabled 
                                          ? Colors.grey.shade600 
                                          : const Color(0xffFFFFFF),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ] else ...[
                  const CountryCodeTextField(),
                  const SizedBox(height: 8),
                  const PhoneNumberTextField(),
                  const SizedBox(height: 20),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return InkWell(
                        onTap: state is SendingOtpState ? null : _sendOtp,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0XFFA342FF), Color(0XFFE54D60)],
                            ),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Center(
                            child: state is SendingOtpState
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Continue",
                                    style: TextStyle(
                                      color: Color(0xffFFFFFF),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(errorMessage),
              if (DevelopmentHelper.isDebugMode &&
                  errorMessage.contains('Too many OTP requests')) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Development Mode',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'This is a common issue during development. Try:',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '• Wait 5-10 minutes before retrying\n• Use a different phone number\n• Check Firebase console for quota limits',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            if (DevelopmentHelper.isDebugMode &&
                errorMessage.contains('Too many OTP requests')) ...[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Show a snackbar with development tip
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Development tip: Wait 5-10 minutes before retrying or use a different phone number.',
                      ),
                      duration: Duration(seconds: 8),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                child: const Text('Development Tip'),
              ),
            ],
          ],
        );
      },
    );
  }
}