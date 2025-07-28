import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Centralized service for all Firestore operations
class FirestoreService {
  static FirebaseFirestore get instance => FirebaseFirestore.instance;
  static FirebaseAuth get auth => FirebaseAuth.instance;

  /// Initialize Firestore with offline persistence
  static Future<void> initialize() async {
    try {
      final settings = Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      instance.settings = settings;
      print('✅ Firestore initialized with offline persistence');
    } catch (e) {
      print('❌ Error initializing Firestore: $e');
      rethrow;
    }
  }

  // AGENT OPERATIONS
  static Future<DocumentSnapshot> getAgentProfile(String agentId) async {
    return await instance.collection('agents').doc(agentId).get();
  }

  static Future<void> setAgentProfile(String agentId, Map<String, dynamic> data) async {
    await instance.collection('agents').doc(agentId).set(data, SetOptions(merge: true));
  }

  static Future<void> updateAgentProfile(String agentId, Map<String, dynamic> data) async {
    await instance.collection('agents').doc(agentId).update(data);
  }

  static Future<void> deleteAgentProfile(String agentId) async {
    await instance.collection('agents').doc(agentId).delete();
  }

  static Stream<DocumentSnapshot> streamAgentProfile(String agentId) {
    return instance.collection('agents').doc(agentId).snapshots();
  }

  // BUSINESS OPERATIONS
  static Future<DocumentSnapshot> getBusinessProfile(String businessId) async {
    return await instance.collection('businesses').doc(businessId).get();
  }

  static Future<void> setBusinessProfile(String businessId, Map<String, dynamic> data) async {
    await instance.collection('businesses').doc(businessId).set(data, SetOptions(merge: true));
  }

  static Future<void> updateBusinessProfile(String businessId, Map<String, dynamic> data) async {
    await instance.collection('businesses').doc(businessId).update(data);
  }

  static Future<void> deleteBusinessProfile(String businessId) async {
    await instance.collection('businesses').doc(businessId).delete();
  }

  static Stream<DocumentSnapshot> streamBusinessProfile(String businessId) {
    return instance.collection('businesses').doc(businessId).snapshots();
  }

  // CUSTOMER OPERATIONS
  static Future<QuerySnapshot> getCustomers(String agentId) async {
    return await instance.collection('customers')
        .where('agentId', isEqualTo: agentId)
        .get();
  }

  static Future<DocumentSnapshot> getCustomer(String customerId) async {
    return await instance.collection('customers').doc(customerId).get();
  }

  static Future<void> setCustomer(String customerId, Map<String, dynamic> data) async {
    await instance.collection('customers').doc(customerId).set(data, SetOptions(merge: true));
  }

  static Future<void> updateCustomer(String customerId, Map<String, dynamic> data) async {
    await instance.collection('customers').doc(customerId).update(data);
  }

  static Future<void> deleteCustomer(String customerId) async {
    await instance.collection('customers').doc(customerId).delete();
  }

  static Stream<QuerySnapshot> streamCustomers(String agentId) {
    return instance.collection('customers')
        .where('agentId', isEqualTo: agentId)
        .snapshots();
  }

  // ORDER OPERATIONS
  static Future<QuerySnapshot> getOrders(String agentId) async {
    return await instance.collection('orders')
        .where('agentId', isEqualTo: agentId)
        .get();
  }

  static Future<DocumentSnapshot> getOrder(String orderId) async {
    return await instance.collection('orders').doc(orderId).get();
  }

  static Future<void> setOrder(String orderId, Map<String, dynamic> data) async {
    await instance.collection('orders').doc(orderId).set(data, SetOptions(merge: true));
  }

  static Future<void> updateOrder(String orderId, Map<String, dynamic> data) async {
    await instance.collection('orders').doc(orderId).update(data);
  }

  static Future<void> deleteOrder(String orderId) async {
    await instance.collection('orders').doc(orderId).delete();
  }

  static Stream<QuerySnapshot> streamOrders(String agentId) {
    return instance.collection('orders')
        .where('agentId', isEqualTo: agentId)
        .snapshots();
  }

  // INVENTORY OPERATIONS
  static Future<QuerySnapshot> getInventory(String agentId) async {
    return await instance.collection('inventory')
        .where('agentId', isEqualTo: agentId)
        .get();
  }

  static Future<DocumentSnapshot> getInventoryItem(String itemId) async {
    return await instance.collection('inventory').doc(itemId).get();
  }

  static Future<void> setInventoryItem(String itemId, Map<String, dynamic> data) async {
    await instance.collection('inventory').doc(itemId).set(data, SetOptions(merge: true));
  }

  static Future<void> updateInventoryItem(String itemId, Map<String, dynamic> data) async {
    await instance.collection('inventory').doc(itemId).update(data);
  }

  static Future<void> deleteInventoryItem(String itemId) async {
    await instance.collection('inventory').doc(itemId).delete();
  }

  static Stream<QuerySnapshot> streamInventory(String agentId) {
    return instance.collection('inventory')
        .where('agentId', isEqualTo: agentId)
        .snapshots();
  }

  // ANALYTICS OPERATIONS
  static Future<void> logAnalyticsEvent(Map<String, dynamic> eventData) async {
    await instance.collection('analytics').add(eventData);
  }

  static Future<QuerySnapshot> getAnalytics(String agentId, DateTime startDate, DateTime endDate) async {
    return await instance.collection('analytics')
        .where('agentId', isEqualTo: agentId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();
  }

  // NOTIFICATION OPERATIONS
  static Future<QuerySnapshot> getNotifications(String agentId) async {
    return await instance.collection('notifications')
        .where('agentId', isEqualTo: agentId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  static Future<void> setNotification(String notificationId, Map<String, dynamic> data) async {
    await instance.collection('notifications').doc(notificationId).set(data, SetOptions(merge: true));
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    await instance.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  static Stream<QuerySnapshot> streamNotifications(String agentId) {
    return instance.collection('notifications')
        .where('agentId', isEqualTo: agentId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // UTILITY OPERATIONS
  static Future<void> updateFCMToken(String agentId, String token) async {
    await instance.collection('agents').doc(agentId).update({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateAgentOnlineStatus(String agentId, bool isOnline) async {
    await instance.collection('agents').doc(agentId).update({
      'isOnline': isOnline,
      'lastSeenAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<bool> documentExists(String collection, String docId) async {
    final doc = await instance.collection(collection).doc(docId).get();
    return doc.exists;
  }

  static Future<bool> collectionExists(String collection) async {
    final snapshot = await instance.collection(collection).limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  static Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    final batch = instance.batch();
    
    for (final operation in operations) {
      final type = operation['type'] as String;
      final collection = operation['collection'] as String;
      final docId = operation['docId'] as String;
      final data = operation['data'] as Map<String, dynamic>?;
      
      final docRef = instance.collection(collection).doc(docId);
      
      switch (type) {
        case 'set':
          batch.set(docRef, data!);
          break;
        case 'update':
          batch.update(docRef, data!);
          break;
        case 'delete':
          batch.delete(docRef);
          break;
      }
    }
    
    await batch.commit();
  }
} 