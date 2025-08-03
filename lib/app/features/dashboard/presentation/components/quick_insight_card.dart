import 'package:flutter/material.dart';
import '../bloc/dashboard_bloc.dart';

class QuickInsightCard extends StatelessWidget {
  final QuickInsightItem insight;
  final VoidCallback? onTap;

  const QuickInsightCard({
    super.key,
    required this.insight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: _getGradientForInsight(insight.id),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
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
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                _getIconFromName(insight.iconName),
                size: 18,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            
            const Spacer(),
            
            // Title
            Text(
              insight.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Value (if needed)
            if (insight.value.isNotEmpty)
              Text(
                insight.value,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Returns different gradient combinations based on insight ID for visual variety
  LinearGradient _getGradientForInsight(String insightId) {
    final int index = insightId.hashCode % 4; // Create 4 different gradient options
    
    switch (index) {
      case 0:
        // Primary app gradient (Purple to Pink-Red)
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA342FF), // Purple
            Color(0xFFE54D60), // Pink-Red
          ],
        );
      case 1:
        // Blue-Purple gradient
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3C29E1), // Blue-Purple
            Color(0xFF603ED9), // Purple
          ],
        );
      case 2:
        // Multi-tone purple gradient
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6725F2), // Deep Purple
            Color(0xFF8A52FF), // Mid Purple
            Color(0xFFE51A5E), // Pink-Red
          ],
        );
      case 3:
      default:
        // Reverse of primary gradient
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE54D60), // Pink-Red
            Color(0xFFA342FF), // Purple
          ],
        );
    }
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
      case 'inventory':
        return Icons.inventory_2_outlined;
      case 'shopping_cart':
        return Icons.shopping_cart_outlined;
      case 'attach_money':
        return Icons.attach_money_outlined;
      default:
        return Icons.info_outline;
    }
  }
} 