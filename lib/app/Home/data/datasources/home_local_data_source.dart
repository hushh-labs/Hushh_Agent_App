import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/home_section_model.dart';
import '../../domain/entities/home_section.dart';

/// Local data source for Home feature
abstract class HomeLocalDataSource {
  Future<List<HomeSectionModel>> getCachedHomeSections();
  Future<void> cacheHomeSections(List<HomeSectionModel> sections);
  Future<Map<String, int>> getCachedNotificationCounts();
  Future<void> cacheNotificationCounts(Map<String, int> counts);
  Future<String?> getActiveSection();
  Future<void> setActiveSection(String sectionId);
  Future<List<String>> getSectionOrder();
  Future<void> setSectionOrder(List<String> sectionIds);
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  static const String _homeSectionsKey = 'home_sections';
  static const String _notificationCountsKey = 'notification_counts';
  static const String _activeSectionKey = 'active_section';
  static const String _sectionOrderKey = 'section_order';

  final SharedPreferences _prefs;

  HomeLocalDataSourceImpl(this._prefs);

  @override
  Future<List<HomeSectionModel>> getCachedHomeSections() async {
    try {
      final sectionsJson = _prefs.getString(_homeSectionsKey);
      if (sectionsJson != null) {
        final List<dynamic> sectionsList = json.decode(sectionsJson);
        return sectionsList
            .map((section) => HomeSectionModel.fromJson(section))
            .toList();
      }
      
      // Return default sections if no cache exists
      return HomeSections.defaultSections
          .map((section) => HomeSectionModel.fromEntity(section))
          .toList();
    } catch (e) {
      throw Exception('Failed to get cached home sections: $e');
    }
  }

  @override
  Future<void> cacheHomeSections(List<HomeSectionModel> sections) async {
    try {
      final sectionsJson = json.encode(
        sections.map((section) => section.toJson()).toList(),
      );
      await _prefs.setString(_homeSectionsKey, sectionsJson);
    } catch (e) {
      throw Exception('Failed to cache home sections: $e');
    }
  }

  @override
  Future<Map<String, int>> getCachedNotificationCounts() async {
    try {
      final countsJson = _prefs.getString(_notificationCountsKey);
      if (countsJson != null) {
        final Map<String, dynamic> countsMap = json.decode(countsJson);
        return countsMap.map((key, value) => MapEntry(key, value as int));
      }
      return {};
    } catch (e) {
      throw Exception('Failed to get cached notification counts: $e');
    }
  }

  @override
  Future<void> cacheNotificationCounts(Map<String, int> counts) async {
    try {
      final countsJson = json.encode(counts);
      await _prefs.setString(_notificationCountsKey, countsJson);
    } catch (e) {
      throw Exception('Failed to cache notification counts: $e');
    }
  }

  @override
  Future<String?> getActiveSection() async {
    return _prefs.getString(_activeSectionKey);
  }

  @override
  Future<void> setActiveSection(String sectionId) async {
    await _prefs.setString(_activeSectionKey, sectionId);
  }

  @override
  Future<List<String>> getSectionOrder() async {
    try {
      final orderJson = _prefs.getString(_sectionOrderKey);
      if (orderJson != null) {
        final List<dynamic> orderList = json.decode(orderJson);
        return orderList.cast<String>();
      }
      
      // Return default order
      return HomeSections.defaultSections.map((section) => section.id).toList();
    } catch (e) {
      throw Exception('Failed to get section order: $e');
    }
  }

  @override
  Future<void> setSectionOrder(List<String> sectionIds) async {
    try {
      final orderJson = json.encode(sectionIds);
      await _prefs.setString(_sectionOrderKey, orderJson);
    } catch (e) {
      throw Exception('Failed to set section order: $e');
    }
  }
} 