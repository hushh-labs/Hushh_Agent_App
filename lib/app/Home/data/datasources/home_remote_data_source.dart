import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/home_section_model.dart';
import '../../../../shared/constants/firestore_constants.dart';

/// Remote data source for Home feature
abstract class HomeRemoteDataSource {
  Future<List<HomeSectionModel>> getHomeSections();
  Future<Map<String, int>> getNotificationCounts();
  Future<void> updateActiveSection(String sectionId);
  Future<void> initializeHomeData();
  Future<List<String>> getSectionOrder();
  Future<void> updateSectionOrder(List<String> sectionIds);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  HomeRemoteDataSourceImpl(this._firestore, this._auth);

  String get _userId => _auth.currentUser?.uid ?? '';

  @override
  Future<List<HomeSectionModel>> getHomeSections() async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final doc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(_userId)
          .collection('home_config')
          .doc('sections')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final sections = data['sections'] as List<dynamic>? ?? [];
        return sections
            .map((section) => HomeSectionModel.fromJson(section))
            .toList();
      }

      // Return default sections if no remote config exists
      return _getDefaultSections();
    } catch (e) {
      throw Exception('Failed to get home sections: $e');
    }
  }

  @override
  Future<Map<String, int>> getNotificationCounts() async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final counts = <String, int>{};

      // Get chat unread count
      final chatQuery = await _firestore
          .collection(FirestoreCollections.chats)
          .where('participants', arrayContains: _userId)
          .where('lastMessage.isRead', isEqualTo: false)
          .get();
      counts['chat'] = chatQuery.docs.length;

      // Get notifications count
      final notificationsQuery = await _firestore
          .collection(FirestoreCollections.users)
          .doc(_userId)
          .collection(FirestoreCollections.notifications)
          .where(FirestoreFields.notificationIsRead, isEqualTo: false)
          .get();
      counts['notifications'] = notificationsQuery.docs.length;

      // Add other notification counts as needed
      counts['dashboard'] = 0;
      counts['profile'] = 0;
      counts['reports'] = 0;

      return counts;
    } catch (e) {
      throw Exception('Failed to get notification counts: $e');
    }
  }

  @override
  Future<void> updateActiveSection(String sectionId) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(_userId)
          .collection('home_config')
          .doc('preferences')
          .set({
        'activeSection': sectionId,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update active section: $e');
    }
  }

  @override
  Future<void> initializeHomeData() async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Initialize default home configuration if it doesn't exist
      final sectionsDoc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(_userId)
          .collection('home_config')
          .doc('sections')
          .get();

      if (!sectionsDoc.exists) {
        final defaultSections = _getDefaultSections();
        await _firestore
            .collection(FirestoreCollections.users)
            .doc(_userId)
            .collection('home_config')
            .doc('sections')
            .set({
          'sections': defaultSections.map((section) => section.toJson()).toList(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to initialize home data: $e');
    }
  }

  @override
  Future<List<String>> getSectionOrder() async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final doc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(_userId)
          .collection('home_config')
          .doc('preferences')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final order = data['sectionOrder'] as List<dynamic>? ?? [];
        return order.cast<String>();
      }

      // Return default order
      return _getDefaultSections().map((section) => section.id).toList();
    } catch (e) {
      throw Exception('Failed to get section order: $e');
    }
  }

  @override
  Future<void> updateSectionOrder(List<String> sectionIds) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(_userId)
          .collection('home_config')
          .doc('preferences')
          .set({
        'sectionOrder': sectionIds,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update section order: $e');
    }
  }

  List<HomeSectionModel> _getDefaultSections() {
    return [
      const HomeSectionModel(
        id: 'dashboard',
        title: 'Dashboard',
        icon: 'dashboard',
        index: 0,
      ),
      const HomeSectionModel(
        id: 'chat',
        title: 'Chat',
        icon: 'chat',
        index: 1,
      ),
      const HomeSectionModel(
        id: 'profile',
        title: 'Profile',
        icon: 'profile',
        index: 2,
      ),
      const HomeSectionModel(
        id: 'reports',
        title: 'Reports',
        icon: 'reports',
        index: 3,
      ),
    ];
  }
} 