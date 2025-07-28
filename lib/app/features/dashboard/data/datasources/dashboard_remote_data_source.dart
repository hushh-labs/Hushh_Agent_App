import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/dashboard_models.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../../../../shared/constants/firestore_constants.dart';

/// Remote data source for Dashboard feature
abstract class DashboardRemoteDataSource {
  Future<DashboardSummaryModel> getDashboardSummary();
  Future<List<ActivityItemModel>> getRecentActivities({int limit = 10});
  Future<List<QuickActionModel>> getQuickActions();
  Future<SalesChartDataModel> getSalesChartData({DateTime? startDate, DateTime? endDate});
  Future<void> refreshDashboardData();
  Future<void> markActivityAsRead(String activityId);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DashboardRemoteDataSourceImpl(this._firestore, this._auth);

  String get _userId => _auth.currentUser?.uid ?? '';

  @override
  Future<DashboardSummaryModel> getDashboardSummary() async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      // Get summary from Firestore or calculate from orders/customers
      final doc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(_userId)
          .collection('dashboard')
          .doc('summary')
          .get();

      if (doc.exists && doc.data() != null) {
        return DashboardSummaryModel.fromJson(doc.data()!);
      }

      // Generate mock summary if no data exists
      return DashboardSummaryModel(
        totalRevenue: 125000.50,
        totalOrders: 89,  
        activeCustomers: 234,
        monthlyGrowth: 12.5,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to get dashboard summary: $e');
    }
  }

  @override
  Future<List<ActivityItemModel>> getRecentActivities({int limit = 10}) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      final query = await _firestore
          .collection('activities')
          .where('agentId', isEqualTo: _userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs
            .map((doc) => ActivityItemModel.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList();
      }

      // Return mock activities if no data exists
      return _getMockActivities();
    } catch (e) {
      // Return mock data on error
      return _getMockActivities();
    }
  }

  @override
  Future<List<QuickActionModel>> getQuickActions() async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      final doc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(_userId)
          .collection('dashboard')
          .doc('quick_actions')
          .get();

      if (doc.exists && doc.data() != null) {
        final actions = doc.data()!['actions'] as List<dynamic>;
        return actions.map((action) => QuickActionModel.fromJson(action)).toList();
      }

      // Return default quick actions
      return _getDefaultQuickActions();
    } catch (e) {
      return _getDefaultQuickActions();
    }
  }

  @override
  Future<SalesChartDataModel> getSalesChartData({DateTime? startDate, DateTime? endDate}) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      // Generate mock chart data for demonstration
      final now = DateTime.now();
      final dailySales = List.generate(30, (index) {
        final date = now.subtract(Duration(days: 29 - index));
        final value = 1000 + (index * 50) + (index % 7 * 200);
        return ChartDataPointModel(
          date: date,
          value: value.toDouble(),
          label: 'Day ${index + 1}',
        );
      });

      final monthlySales = List.generate(12, (index) {
        final date = DateTime(now.year, index + 1);
        final value = 15000 + (index * 2000) + (index % 3 * 5000);
        return ChartDataPointModel(
          date: date,
          value: value.toDouble(),
          label: 'Month ${index + 1}',
        );
      });

      return SalesChartDataModel(
        dailySales: dailySales,
        monthlySales: monthlySales,
        totalRevenue: 125000.50,
        averageDailySales: 2500.75,
      );
    } catch (e) {
      throw Exception('Failed to get sales chart data: $e');
    }
  }

  @override
  Future<void> refreshDashboardData() async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      // Update the last refreshed timestamp
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(_userId)
          .collection('dashboard')
          .doc('metadata')
          .set({
        'lastRefreshed': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to refresh dashboard data: $e');
    }
  }

  @override
  Future<void> markActivityAsRead(String activityId) async {
    try {
      if (_userId.isEmpty) throw Exception('User not authenticated');

      await _firestore
          .collection('activities')
          .doc(activityId)
          .update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark activity as read: $e');
    }
  }

  List<ActivityItemModel> _getMockActivities() {
    final now = DateTime.now();
    return [
      ActivityItemModel(
        id: '1',
        title: 'New Order Received',
        description: 'Order #1234 from John Doe',
        type: ActivityType.order,
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      ActivityItemModel(
        id: '2', 
        title: 'Payment Confirmed',
        description: 'Payment of ₹5,000 received',
        type: ActivityType.payment,
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      ActivityItemModel(
        id: '3',
        title: 'New Customer Registration',
        description: 'Jane Smith joined as a customer',
        type: ActivityType.customer,
        timestamp: now.subtract(const Duration(hours: 4)),
      ),
    ];
  }

  List<QuickActionModel> _getDefaultQuickActions() {
    return [
      const QuickActionModel(
        id: 'add_order',
        title: 'Add Order',
        description: 'Create a new order',
        icon: 'add_shopping_cart',
        route: '/orders/add',
      ),
      const QuickActionModel(
        id: 'manage_inventory',
        title: 'Manage Inventory',
        description: 'Update product stock',
        icon: 'inventory',
        route: '/inventory',
      ),
      const QuickActionModel(
        id: 'customer_support',
        title: 'Customer Support',
        description: 'Help customers',
        icon: 'support_agent',
        route: '/chat',
      ),
      const QuickActionModel(
        id: 'view_reports',
        title: 'View Reports',
        description: 'Business analytics',
        icon: 'analytics',
        route: '/reports',
      ),
    ];
  }
} 