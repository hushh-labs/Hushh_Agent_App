import 'package:flutter/material.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardTabBar extends StatelessWidget {
  final DashboardTab selectedTab;
  final Function(DashboardTab) onTabSelected;
  final VoidCallback? onRefresh;

  const DashboardTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Services Tab
          GestureDetector(
            onTap: () => onTabSelected(DashboardTab.services),
            child: Container(
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selectedTab == DashboardTab.services 
                        ? const Color(0xFFE91E63)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                'Services',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: selectedTab == DashboardTab.services 
                      ? const Color(0xFFE91E63)
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 32),
          
          // Customers Tab
          GestureDetector(
            onTap: () => onTabSelected(DashboardTab.customers),
            child: Container(
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selectedTab == DashboardTab.customers 
                        ? const Color(0xFFE91E63)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                'Customers',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: selectedTab == DashboardTab.customers 
                      ? const Color(0xFFE91E63)
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ),
          
          const Spacer(),
          
          // Refresh Button
          GestureDetector(
            onTap: onRefresh,
            child: Icon(
              Icons.refresh,
              color: Colors.grey.shade600,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
} 