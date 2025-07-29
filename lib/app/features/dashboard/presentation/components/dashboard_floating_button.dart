import 'package:flutter/material.dart';

class DashboardFloatingButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const DashboardFloatingButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: const Color(0xFFE91E63),
      elevation: 8,
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 28,
      ),
    );
  }
} 