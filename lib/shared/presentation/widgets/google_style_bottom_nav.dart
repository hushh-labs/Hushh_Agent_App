import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_routes.dart';
import '../../utils/app_local_storage.dart';

/// Google-style bottom navigation bar component with complete animation system
class GoogleStyleBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavItem> items;
  final Function(int) onTap;
  final bool isAgentApp;

  const GoogleStyleBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.isAgentApp = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Outer container with shadow and styling
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08), // Subtle shadow
            blurRadius: 12,                               // Soft blur effect
            offset: const Offset(0, -3),                 // Shadow above the bar
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 53,                                     // Fixed height
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildNavItem(
                context: context,
                item: item,
                index: index,
                isSelected: index == currentIndex,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Individual Navigation Item with Animations
  Widget _buildNavItem({
    required BuildContext context,
    required BottomNavItem item,
    required int index,
    required bool isSelected,
  }) {
    final isRestrictedForGuest = AppLocalStorage.isGuestMode && item.isRestrictedForGuest;

    return GestureDetector(
      onTap: () {
        // HAPTIC FEEDBACK ANIMATION
        HapticFeedback.lightImpact();              // Physical vibration feedback
        
        if (isRestrictedForGuest) {
          _showGuestAccessDialog(context, item.label);
          return;
        }
        onTap(index);
      },
      behavior: HitTestBehavior.translucent,       // Full area touch detection
      
      // MAIN ANIMATION CONTAINER
      child: AnimatedContainer(
        // ANIMATION TIMING & CURVES
        duration: const Duration(milliseconds: 300),  // Smooth transition timing
        curve: Curves.ease,                           // Easing animation curve
        
        // DYNAMIC PADDING ANIMATION
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16.0 : 8.0,       // Expand/contract horizontally
          vertical: isSelected ? 10.0 : 4.0,         // Expand/contract vertically
        ),
        
        // BACKGROUND DECORATION ANIMATION
        decoration: BoxDecoration(
          // COLOR & GRADIENT ANIMATIONS
          color: isSelected ? const Color(0xFF616180) : Colors.transparent,
          gradient: isSelected
              ? const LinearGradient(                 // Gradient for selected state
                  colors: [Colors.purple, Colors.pinkAccent]
                )
              : null,                                 // No gradient for unselected
          borderRadius: BorderRadius.circular(20.0),  // Rounded corners
        ),
        
        // CONTENT LAYOUT
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ICON WITH COLOR ANIMATION
            _buildIcon(
              item: item,
              isSelected: isSelected,
              isRestricted: isRestrictedForGuest,
            ),
            
            // CONDITIONAL TEXT ANIMATION (Show/Hide)
            if (isSelected) ...[
              const SizedBox(width: 6.0),            // Spacing animation
              Text(
                item.label,
                style: const TextStyle(
                  color: Colors.white,               // White text on gradient
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Icon Animation & Color Transitions
  Widget _buildIcon({
    required BottomNavItem item,
    required bool isSelected,
    required bool isRestricted,
  }) {
    // DYNAMIC COLOR CALCULATION
    final Color iconColor = isSelected
        ? Colors.white                              // Selected: White
        : (isRestricted 
            ? Colors.grey[400]!                     // Restricted: Gray
            : const Color(0xFF616180));             // Default: Dark gray

    // SVG ICON WITH COLOR FILTER ANIMATION (with error handling)
    if (item.iconPath != null) {
      return SvgPicture.asset(
        item.iconPath!,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn), // Color animation
        width: 20,
        height: 20,
        // Fallback to Material icon if SVG fails to load
        placeholderBuilder: (context) => Icon(
          item.icon ?? Icons.circle,
          color: iconColor,
          size: 20,
        ),
      );
    } 
    // MATERIAL ICON WITH COLOR ANIMATION
    else if (item.icon != null) {
      return Icon(
        item.icon, 
        color: iconColor,                           // Animated color transition
        size: 20
      );
    }
    
    // FALLBACK ICON
    return Icon(
      Icons.circle,
      color: iconColor,
      size: 20,
    );
  }

  /// Guest Access Dialog Animation
  void _showGuestAccessDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(                         // Built-in fade animation
          title: const Text('Sign In Required'),
          content: Text('Please sign in to access $featureName.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                AppLocalStorage.setGuestMode(false);
                Navigator.pushReplacementNamed(context, AppRoutes.mainAuth);
              },
              child: const Text('Sign In'),
            ),
          ],
        );
      },
    );
  }
}

/// BottomNavItem Data Structure
class BottomNavItem {
  final String label;
  final String? iconPath;                         // For SVG icons
  final IconData? icon;                           // For Material icons
  final bool isRestrictedForGuest;

  const BottomNavItem({
    required this.label,
    this.iconPath,
    this.icon,
    this.isRestrictedForGuest = false,
  });

  // Factory constructors for different app types
  factory BottomNavItem.user({
    required String label,
    String? iconPath,
    IconData? icon,
    bool isRestrictedForGuest = false,
  }) {
    return BottomNavItem(
      label: label,
      iconPath: iconPath,
      icon: icon,
      isRestrictedForGuest: isRestrictedForGuest,
    );
  }

  factory BottomNavItem.agent({
    required String label,
    String? iconPath,
    IconData? icon,
    bool isRestrictedForGuest = false,
  }) {
    return BottomNavItem(
      label: label,
      iconPath: iconPath,
      icon: icon,
      isRestrictedForGuest: isRestrictedForGuest,
    );
  }
}
