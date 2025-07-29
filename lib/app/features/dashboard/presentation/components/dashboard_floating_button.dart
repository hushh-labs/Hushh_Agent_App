import 'package:flutter/material.dart';

class DashboardFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DashboardFloatingButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: const Color(0xFFE91E63),
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(
        Icons.qr_code_scanner,
        color: Colors.white,
        size: 28,
      ),
    );
  }
} 