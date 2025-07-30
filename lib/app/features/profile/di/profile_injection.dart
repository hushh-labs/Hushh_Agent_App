import 'package:get_it/get_it.dart';
import '../presentation/bloc/profile_bloc.dart';

final sl = GetIt.instance;

void initializeProfileFeature() {
  // Register ProfileBloc as a factory
  sl.registerFactory<ProfileBloc>(() => ProfileBloc());
}
