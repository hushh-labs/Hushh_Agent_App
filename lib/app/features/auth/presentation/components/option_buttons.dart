import 'package:flutter/material.dart';
import '../../../../../shared/core/utils/screen_utils.dart';

// the widget for the every common options ....

class OptionButtons extends StatelessWidget {
  final String title;
  final IconData icon;
  const OptionButtons({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    var height = context.screenHeight;
    var width = context.screenWidth;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10, left: 10, top: 3, bottom: 3),
            child: Icon(icon, color: Colors.black, size: 20),
          ),
          Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black)),
        ],
      ),
    );
  }
}
