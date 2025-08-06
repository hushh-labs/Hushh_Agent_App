import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Home Feature Imports
import '../presentation/bloc/home_bloc.dart';
import '../domain/repositories/home_repository.dart';
import '../domain/usecases/get_home_sections_usecase.dart';
import '../domain/usecases/initialize_home_usecase.dart';
import '../data/repositories/home_repository_impl.dart';
import '../data/datasources/home_local_data_source.dart';
import '../data/datasources/home_remote_data_source.dart';
import '../../features/notification_bidding/domain/usecases/refresh_fcm_token_usecase.dart';
import '../../features/notification_bidding/domain/repositories/notification_bidding_repository.dart';

/// Service locator instance
final sl = GetIt.instance;

/// Initialize Home Feature dependencies using Clean Architecture
Future<void> initializeHomeFeature() async {
  // ===== DATA SOURCES =====
  // Get SharedPreferences instance
  final sharedPreferences = await SharedPreferences.getInstance();

  // Home Local Data Source
  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(sharedPreferences),
  );

  // Home Remote Data Source
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(
      FirebaseFirestore.instance,
      FirebaseAuth.instance,
    ),
  );

  // ===== REPOSITORIES =====
  // Home Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      sl<HomeLocalDataSource>(),
      sl<HomeRemoteDataSource>(),
    ),
  );

  // ===== USE CASES =====
  // Get Home Sections Use Case
  sl.registerLazySingleton<GetHomeSectionsUseCase>(
    () => GetHomeSectionsUseCase(sl<HomeRepository>()),
  );

  // Initialize Home Use Case
  sl.registerLazySingleton<InitializeHomeUseCase>(
    () => InitializeHomeUseCase(sl<HomeRepository>()),
  );

  // ===== BLOCS =====
  // Home BLoC with Firebase Auth for routing decisions
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(
      getHomeSectionsUseCase: sl<GetHomeSectionsUseCase>(),
      initializeHomeUseCase: sl<InitializeHomeUseCase>(),
      refreshFcmTokenUseCase: sl<RefreshFcmTokenUseCase>(),
      firebaseAuth: FirebaseAuth.instance,
    ),
  );

  print('✅ [DI] Home feature dependencies registered with routing support');
}
