import '../entities/home_section.dart';

/// Repository interface for Home feature
abstract class HomeRepository {
  /// Get all available home sections
  Future<List<HomeSection>> getHomeSections();
  
  /// Get notification counts for sections
  Future<Map<String, int>> getNotificationCounts();
  
  /// Update the active section
  Future<void> updateActiveSection(String sectionId);
  
  /// Initialize home data
  Future<void> initializeHome();
  
  /// Get user's preferred section order
  Future<List<String>> getSectionOrder();
  
  /// Update section order
  Future<void> updateSectionOrder(List<String> sectionIds);
} 