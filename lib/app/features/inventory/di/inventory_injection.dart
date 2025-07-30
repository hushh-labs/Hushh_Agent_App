import 'package:get_it/get_it.dart';
import '../presentation/bloc/lookbook_bloc.dart';

final sl = GetIt.instance;

void initializeInventoryFeature() {
  // Register LookbookBloc as a factory
  sl.registerFactory<LookbookBloc>(() => LookbookBloc());

  print('✅ [DI] Inventory feature dependencies registered');
}
