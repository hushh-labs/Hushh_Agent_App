import 'package:flutter/material.dart';
import '../bloc/dashboard_bloc.dart';

class QuickInsightCard extends StatelessWidget {
  final QuickInsightItem insight;

  const QuickInsightCard({
    super.key,
    required this.insight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: insight.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFCE4EC), // Light pink background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFF8BBD9).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF8BBD9).withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                _getIconFromName(insight.iconName),
                size: 18,
                color: const Color(0xFF8B5A7C), // Darker pink for icons
              ),
            ),
            
            const Spacer(),
            
            // Title
            Text(
              insight.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D), // Dark text
                height: 1.2,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Value (if needed)
            if (insight.value.isNotEmpty)
              Text(
                insight.value,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666), // Medium gray
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'people':
        return Icons.people_outline;
      case 'calendar':
        return Icons.calendar_today_outlined;
      case 'shield':
        return Icons.shield_outlined;
      case 'trending_up':
        return Icons.trending_up;
      default:
        return Icons.info_outline;
    }
  }
} 