import '../../domain/entities/home_section.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_data_source.dart';
import '../datasources/home_remote_data_source.dart';
import '../models/home_section_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource _localDataSource;
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<List<HomeSection>> getHomeSections() async {
    try {
      // Try to get from remote first
      final remoteSections = await _remoteDataSource.getHomeSections();
      
      // Cache the remote data
      await _localDataSource.cacheHomeSections(remoteSections);
      
      return remoteSections;
    } catch (e) {
      // Fallback to local data if remote fails
      try {
        final localSections = await _localDataSource.getCachedHomeSections();
        return localSections;
      } catch (localError) {
        // If both fail, return default sections
        return HomeSections.defaultSections;
      }
    }
  }

  @override
  Future<Map<String, int>> getNotificationCounts() async {
    try {
      // Try to get from remote first
      final remoteCounts = await _remoteDataSource.getNotificationCounts();
      
      // Cache the remote data
      await _localDataSource.cacheNotificationCounts(remoteCounts);
      
      return remoteCounts;
    } catch (e) {
      // Fallback to local data if remote fails
      try {
        final localCounts = await _localDataSource.getCachedNotificationCounts();
        return localCounts;
      } catch (localError) {
        // If both fail, return empty counts
        return {};
      }
    }
  }

  @override
  Future<void> updateActiveSection(String sectionId) async {
    try {
      // Update both local and remote
      await Future.wait([
        _localDataSource.setActiveSection(sectionId),
        _remoteDataSource.updateActiveSection(sectionId),
      ]);
    } catch (e) {
      // At least update local if remote fails
      await _localDataSource.setActiveSection(sectionId);
      rethrow;
    }
  }

  @override
  Future<void> initializeHome() async {
    try {
      await _remoteDataSource.initializeHomeData();
    } catch (e) {
      // Continue even if remote initialization fails
      print('Remote home initialization failed: $e');
    }
  }

  @override
  Future<List<String>> getSectionOrder() async {
    try {
      // Try to get from remote first
      final remoteOrder = await _remoteDataSource.getSectionOrder();
      
      // Cache the remote data
      await _localDataSource.setSectionOrder(remoteOrder);
      
      return remoteOrder;
    } catch (e) {
      // Fallback to local data if remote fails
      try {
        final localOrder = await _localDataSource.getSectionOrder();
        return localOrder;
      } catch (localError) {
        // If both fail, return default order
        return HomeSections.defaultSections.map((section) => section.id).toList();
      }
    }
  }

  @override
  Future<void> updateSectionOrder(List<String> sectionIds) async {
    try {
      // Update both local and remote
      await Future.wait([
        _localDataSource.setSectionOrder(sectionIds),
        _remoteDataSource.updateSectionOrder(sectionIds),
      ]);
    } catch (e) {
      // At least update local if remote fails
      await _localDataSource.setSectionOrder(sectionIds);
      rethrow;
    }
  }
} 