import 'package:get_it/get_it.dart';

// Splash Feature Imports
import '../../../splash/data/datasources/splash_local_data_source.dart';
import '../../../splash/data/datasources/splash_remote_data_source.dart';
import '../../../splash/data/repositories/splash_repository_impl.dart';
import '../../../splash/domain/repositories/splash_repository.dart';
import '../../../splash/domain/usecases/initialize_app_usecase.dart';
import '../../../splash/domain/usecases/check_authentication_usecase.dart';
import '../../../splash/presentation/bloc/splash_bloc.dart';

/// Service locator instance
final sl = GetIt.instance;

/// Initialize Splash Feature dependencies using Clean Architecture
void initializeSplashFeature() {
  // ===== DATA SOURCES =====
  // Splash Local Data Source
  sl.registerLazySingleton<SplashLocalDataSource>(
    () => SplashLocalDataSourceImpl(),
  );
  
  // Splash Remote Data Source  
  sl.registerLazySingleton<SplashRemoteDataSource>(
    () => SplashRemoteDataSourceImpl(),
  );
  
  // ===== REPOSITORIES =====
  // Splash Repository
  sl.registerLazySingleton<SplashRepository>(
    () => SplashRepositoryImpl(
      localDataSource: sl<SplashLocalDataSource>(),
      remoteDataSource: sl<SplashRemoteDataSource>(),
    ),
  );
  
  // ===== USE CASES =====
  // Initialize App Use Case
  sl.registerLazySingleton<InitializeAppUseCase>(
    () => InitializeAppUseCase(sl<SplashRepository>()),
  );
  
  // Check Authentication Use Case
  sl.registerLazySingleton<CheckAuthenticationUseCase>(
    () => CheckAuthenticationUseCase(sl<SplashRepository>()),
  );
  
  // ===== BLOCS =====
  // Splash BLoC
  sl.registerFactory<SplashBloc>(
    () => SplashBloc(
      initializeAppUseCase: sl<InitializeAppUseCase>(),
      checkAuthenticationUseCase: sl<CheckAuthenticationUseCase>(),
    ),
  );
  
  print('✅ [DI] Splash feature dependencies registered');
}

/// Example of how to use in your main app:
/// 
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   
///   // Initialize splash feature dependencies
///   initializeSplashFeature();
///   
///   runApp(MyApp());
/// }
/// 
/// // In your app widget:
/// BlocProvider(
///   create: (context) => sl<SplashBloc>(),
///   child: const SplashPageWithBloc(),
/// )
/// ```
///
/// Service Locator Pattern Explanation:
/// 
/// `sl` stands for "Service Locator" and is the GetIt instance used for 
/// Dependency Injection throughout the application.
/// 
/// Benefits:
/// - Centralized dependency management
/// - Easy testing with mock implementations
/// - Loose coupling between layers
/// - Single responsibility principle
/// 
/// Usage Example:
/// ```dart
/// // Get registered dependencies
/// final bloc = sl<SplashBloc>();
/// final repository = sl<SplashRepository>();
/// 
/// // Use in BLoC provider
/// BlocProvider(
///   create: (context) => sl<SplashBloc>(),
///   child: YourWidget(),
/// )
/// ``` 