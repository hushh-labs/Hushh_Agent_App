import 'package:get_it/get_it.dart';

// Home Feature Imports
import '../presentation/bloc/home_bloc.dart';

/// Service locator instance
final sl = GetIt.instance;

/// Initialize Home Feature dependencies using Clean Architecture
void initializeHomeFeature() {
  // ===== BLOCS =====
  // Home BLoC
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(),
  );
} 