import 'package:flutter/material.dart';

class ProfileMenuItem {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;
  final bool showArrow;

  const ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.onTap,
    this.showArrow = true,
  });
} 