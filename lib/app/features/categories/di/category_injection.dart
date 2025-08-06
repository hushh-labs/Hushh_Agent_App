import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Data Layer
import '../data/datasources/category_remote_data_source.dart';
import '../data/repositories/category_repository_impl.dart';

// Domain Layer
import '../domain/repositories/category_repository.dart';
import '../domain/usecases/get_categories_usecase.dart';
import '../domain/usecases/upload_categories_usecase.dart';

final sl = GetIt.instance;

/// Initialize all dependencies for the categories feature
Future<void> initializeCategoryFeature() async {
  print('🔧 Initializing Categories Feature dependencies...');

  // External dependencies
  if (!sl.isRegistered<FirebaseFirestore>()) {
    sl.registerLazySingleton<FirebaseFirestore>(
        () => FirebaseFirestore.instance);
  }

  // Data sources
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => UploadCategoriesUseCase(sl()));

  print('✅ Categories Feature dependencies initialized successfully!');
}

/// Clean up all category-related dependencies
void cleanupCategoryFeature() {
  print('🧹 Cleaning up Categories Feature dependencies...');

  // Use cases
  if (sl.isRegistered<GetCategoriesUseCase>()) {
    sl.unregister<GetCategoriesUseCase>();
  }
  if (sl.isRegistered<UploadCategoriesUseCase>()) {
    sl.unregister<UploadCategoriesUseCase>();
  }

  // Repositories
  if (sl.isRegistered<CategoryRepository>()) {
    sl.unregister<CategoryRepository>();
  }

  // Data sources
  if (sl.isRegistered<CategoryRemoteDataSource>()) {
    sl.unregister<CategoryRemoteDataSource>();
  }

  print('✅ Categories Feature dependencies cleaned up successfully!');
}
