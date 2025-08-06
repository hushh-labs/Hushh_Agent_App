import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class OnboardingWidget extends StatefulWidget {
  final imagePath;
  final title;
  final desc;

  OnboardingWidget({this.imagePath, this.title, this.desc});

  @override
  _OnboardingWidgetState createState() =>
      _OnboardingWidgetState(this.imagePath, this.title, this.desc);
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  final imagePath;
  final title;
  final desc;

  _OnboardingWidgetState(this.imagePath, this.title, this.desc);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Lottie.asset(
          imagePath,
          width: double.infinity,
          height: 20.h,
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 24,
                  color: Colors.black),
            ),
          ),
        ),
        const SizedBox(
          height: 16.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Text(
            desc,
            softWrap: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
