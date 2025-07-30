import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../components/otp_heading_section.dart';
import '../components/otp_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../../domain/enum.dart';
import '../../../../../shared/core/routing/routes.dart';
import '../../../../../shared/constants/app_routes.dart';

class OtpVerificationPageArgs {
  final String emailOrPhone;
  final OtpVerificationType type;

  OtpVerificationPageArgs({required this.emailOrPhone, required this.type});
}

class OtpVerificationPage extends StatefulWidget {
  final OtpVerificationPageArgs args;
  const OtpVerificationPage({super.key, required this.args});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController otpController = TextEditingController();
  int countDownForResendStartValue = 60;
  late Timer countDownForResend;
  bool resendValidation = false;

  void countDownForResendFunction() {
    const oneSec = Duration(seconds: 1);
    countDownForResend = Timer.periodic(oneSec, (Timer timer) {
      if (countDownForResendStartValue == 0) {
        setState(() {
          timer.cancel();
          resendValidation = true;
          countDownForResendStartValue = 60;
        });
      } else {
        setState(() {
          countDownForResendStartValue--;
        });
      }
    });
  }

  @override
  void initState() {
    otpController.clear();
    countDownForResendFunction();
    super.initState();
  }

  @override
  void dispose() {
    countDownForResend.cancel();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;

    return Scaffold(
        backgroundColor: Colors.white,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is OtpVerifiedState) {
              // New user - Navigate to agent profile flow after successful verification
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.agentProfileEmail,
                (route) => false,
              );
            } else if (state is ExistingUserVerifiedState) {
              // Existing user with complete profile - Navigate directly to main page
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.home,
                (route) => false,
              );
            } else if (state is UserProfileCompleteState) {
              if (state.isComplete) {
                // User has complete profile - go to dashboard
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.home,
                  (route) => false,
                );
              } else {
                // User has incomplete profile - go to profile creation flow
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.agentProfileEmail,
                  (route) => false,
                );
              }
            } else if (state is OtpVerificationFailureState) {
              // Show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Verification Failed: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Material(
            color: Colors.white,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - kToolbarHeight,
                  padding: const EdgeInsets.all(20.0).copyWith(top: 12),
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
                                border:
                                    Border.all(color: const Color(0xFFD8DADC)),
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
                      const SizedBox(height: 26 * 3),
                      OtpHeadingSection(
                        title: args.type == OtpVerificationType.email
                            ? 'Verify your Email'
                            : 'Verify your phone number',
                        subtitle: args.type == OtpVerificationType.email
                            ? "We've sent an OTP with an activation code to your email "
                            : "We've sent an SMS with an activation code to your phone ",
                        emailOrPhone: args.emailOrPhone,
                      ),
                      const Expanded(child: SizedBox()),
                      Expanded(
                        flex: 10,
                        child: OtpTextField(
                          controller: otpController,
                          onCompleted: (String value) {
                            // Handle OTP completion
                            // TODO: Replace with proper logging
                            // print('OTP completed: $value');
                          },
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return InkWell(
                                onTap: state is VerifyingOtpState
                                    ? null
                                    : () {
                                        print('OTP Verification button tapped');
                                        print(
                                            'OTP length: ${otpController.text.length}');
                                        print(
                                            'OTP value: ${otpController.text}');
                                        print('Type: ${args.type}');
                                        print(
                                            'Email/Phone: ${args.emailOrPhone}');

                                        if (otpController.text.length == 6) {
                                          if (args.type ==
                                              OtpVerificationType.email) {
                                            print(
                                                'Triggering email OTP verification');
                                            context.read<AuthBloc>().add(
                                                  VerifyEmailOtpEvent(
                                                    email: args.emailOrPhone,
                                                    otp: otpController.text,
                                                  ),
                                                );
                                          } else {
                                            print(
                                                'Triggering phone OTP verification');
                                            context.read<AuthBloc>().add(
                                                  VerifyPhoneOtpEvent(
                                                    phoneNumber:
                                                        args.emailOrPhone,
                                                    otp: otpController.text,
                                                  ),
                                                );
                                          }
                                        } else {
                                          print(
                                              'OTP length is not 6: ${otpController.text.length}');
                                        }
                                      },
                                child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0XFFA342FF),
                                        Color(0XFFE54D60),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Center(
                                    child: state is VerifyingOtpState
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text(
                                            "Verify",
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
                      ),
                      TextButton(
                        onPressed: () {
                          if (countDownForResendStartValue.toString() == "60") {
                            countDownForResendFunction();

                            // Resend OTP based on type
                            if (args.type == OtpVerificationType.email) {
                              context.read<AuthBloc>().add(
                                    SendEmailOtpEvent(args.emailOrPhone),
                                  );
                            } else {
                              context.read<AuthBloc>().add(
                                    SendPhoneOtpEvent(args.emailOrPhone),
                                  );
                            }

                            // Show confirmation message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  args.type == OtpVerificationType.email
                                      ? 'OTP sent to your email'
                                      : 'OTP sent to your phone',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        child: countDownForResendStartValue.toString().length ==
                                1
                            ? RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black.withValues(alpha: 0.7),
                                  ),
                                  children: <TextSpan>[
                                    const TextSpan(text: "Didn't receive?"),
                                    TextSpan(
                                      text: ' Resend',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: countDownForResendStartValue
                                                    .toString() ==
                                                "60"
                                            ? TextDecoration.underline
                                            : null,
                                        color: countDownForResendStartValue
                                                    .toString() ==
                                                "60"
                                            ? Colors.black
                                            : const Color(0xffA3A3A3),
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' in 0$countDownForResendStartValue seconds',
                                    ),
                                  ],
                                ),
                              )
                            : RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black.withValues(alpha: 0.7),
                                  ),
                                  children: <TextSpan>[
                                    const TextSpan(text: "Didn't receive? "),
                                    TextSpan(
                                      text: 'Resend',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: countDownForResendStartValue
                                                    .toString() ==
                                                "60"
                                            ? TextDecoration.underline
                                            : null,
                                        color: countDownForResendStartValue
                                                    .toString() ==
                                                "60"
                                            ? Colors.black
                                            : const Color(0xffA3A3A3),
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' in $countDownForResendStartValue seconds',
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
