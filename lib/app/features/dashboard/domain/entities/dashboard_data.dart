import 'package:equatable/equatable.dart';

/// Dashboard summary statistics
class DashboardSummary extends Equatable {
  final double totalRevenue;
  final int totalOrders;
  final int activeCustomers;
  final double monthlyGrowth;
  final DateTime lastUpdated;

  const DashboardSummary({
    required this.totalRevenue,
    required this.totalOrders,
    required this.activeCustomers,
    required this.monthlyGrowth,
    required this.lastUpdated,
  });

  @override
  List<Object> get props => [
        totalRevenue,
        totalOrders,
        activeCustomers,
        monthlyGrowth,
        lastUpdated,
      ];
}

/// Recent activity item
class ActivityItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final ActivityType type;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    this.metadata,
  });

  @override
  List<Object?> get props => [id, title, description, type, timestamp, metadata];
}

/// Types of activities
enum ActivityType {
  order,
  customer,
  payment,
  inventory,
  message,
  review,
}

/// Quick action item
class QuickAction extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String route;
  final bool isEnabled;

  const QuickAction({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    this.isEnabled = true,
  });

  @override
  List<Object> get props => [id, title, description, icon, route, isEnabled];
}

/// Chart data point
class ChartDataPoint extends Equatable {
  final DateTime date;
  final double value;
  final String? label;

  const ChartDataPoint({
    required this.date,
    required this.value,
    this.label,
  });

  @override
  List<Object?> get props => [date, value, label];
}

/// Sales chart data
class SalesChartData extends Equatable {
  final List<ChartDataPoint> dailySales;
  final List<ChartDataPoint> monthlySales;
  final double totalRevenue;
  final double averageDailySales;

  const SalesChartData({
    required this.dailySales,
    required this.monthlySales,
    required this.totalRevenue,
    required this.averageDailySales,
  });

  @override
  List<Object> get props => [dailySales, monthlySales, totalRevenue, averageDailySales];
} 