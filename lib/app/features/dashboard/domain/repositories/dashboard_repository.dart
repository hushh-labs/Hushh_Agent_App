import '../entities/dashboard_data.dart';

/// Repository interface for Dashboard feature
abstract class DashboardRepository {
  /// Get dashboard summary statistics
  Future<DashboardSummary> getDashboardSummary();
  
  /// Get recent activities
  Future<List<ActivityItem>> getRecentActivities({int limit = 10});
  
  /// Get quick actions for the user
  Future<List<QuickAction>> getQuickActions();
  
  /// Get sales chart data
  Future<SalesChartData> getSalesChartData({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  /// Refresh dashboard data
  Future<void> refreshDashboardData();
  
  /// Mark activity as read
  Future<void> markActivityAsRead(String activityId);
} 