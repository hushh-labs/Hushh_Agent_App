import '../../domain/entities/dashboard_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for DashboardSummary
class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.totalRevenue,
    required super.totalOrders,
    required super.activeCustomers,
    required super.monthlyGrowth,
    required super.lastUpdated,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalOrders: json['totalOrders'] as int,
      activeCustomers: json['activeCustomers'] as int,
      monthlyGrowth: (json['monthlyGrowth'] as num).toDouble(),
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'activeCustomers': activeCustomers,
      'monthlyGrowth': monthlyGrowth,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}

/// Data model for ActivityItem
class ActivityItemModel extends ActivityItem {
  const ActivityItemModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.timestamp,
    super.metadata,
  });

  factory ActivityItemModel.fromJson(Map<String, dynamic> json) {
    return ActivityItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.order,
      ),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }
}

/// Data model for QuickAction
class QuickActionModel extends QuickAction {
  const QuickActionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.icon,
    required super.route,
    super.isEnabled = true,
  });

  factory QuickActionModel.fromJson(Map<String, dynamic> json) {
    return QuickActionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      route: json['route'] as String,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'route': route,
      'isEnabled': isEnabled,
    };
  }
}

/// Data model for ChartDataPoint
class ChartDataPointModel extends ChartDataPoint {
  const ChartDataPointModel({
    required super.date,
    required super.value,
    super.label,
  });

  factory ChartDataPointModel.fromJson(Map<String, dynamic> json) {
    return ChartDataPointModel(
      date: (json['date'] as Timestamp).toDate(),
      value: (json['value'] as num).toDouble(),
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': Timestamp.fromDate(date),
      'value': value,
      'label': label,
    };
  }
}

/// Data model for SalesChartData
class SalesChartDataModel extends SalesChartData {
  const SalesChartDataModel({
    required super.dailySales,
    required super.monthlySales,
    required super.totalRevenue,
    required super.averageDailySales,
  });

  factory SalesChartDataModel.fromJson(Map<String, dynamic> json) {
    return SalesChartDataModel(
      dailySales: (json['dailySales'] as List<dynamic>)
          .map((e) => ChartDataPointModel.fromJson(e))
          .toList(),
      monthlySales: (json['monthlySales'] as List<dynamic>)
          .map((e) => ChartDataPointModel.fromJson(e))
          .toList(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      averageDailySales: (json['averageDailySales'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailySales': dailySales.map((e) => (e as ChartDataPointModel).toJson()).toList(),
      'monthlySales': monthlySales.map((e) => (e as ChartDataPointModel).toJson()).toList(),
      'totalRevenue': totalRevenue,
      'averageDailySales': averageDailySales,
    };
  }
} 