import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../db/app_database.dart';
import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../../data/datasources/purchase_plan_local_data_source.dart';
import '../../data/datasources/shopping_list_plan_local_data_source.dart';
import '../../data/datasources/recipe_local_data_source.dart';
import '../../data/datasources/recipe_remote_data_source.dart';
import '../../data/datasources/optimizer_remote_data_source.dart';
import '../../data/repositories/purchase_plan_repository_impl.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../domain/repositories/purchase_plan_repository.dart';
import '../../domain/repositories/recipe_repository.dart';

final sl = GetIt.I;

Future<void> setupInjector() async {
  // Netwerk client
  sl.registerLazySingleton<Dio>(() => DioClient.build());

  // Database (async singleton)
  sl.registerSingletonAsync<AppDatabase>(() async {
    final db = AppDatabase();
    await db.init();
    return db;
  });

  // Datasources
  sl.registerLazySingleton<RecipeRemoteDataSource>(
    () => RecipeRemoteDataSource(sl<Dio>()),
  );
  sl.registerLazySingleton<OptimizerRemoteDataSource>(
    () => OptimizerRemoteDataSource(
      DioClient.build(baseUrl: AppConfig.optimizerBaseUrl),
    ),
  );
  sl.registerLazySingleton<RecipeLocalDataSource>(
    () => RecipeLocalDataSource(sl<AppDatabase>()),
  );
  sl.registerLazySingleton<PurchasePlanLocalDataSource>(
    () => PurchasePlanLocalDataSource(sl<AppDatabase>()),
  );
  sl.registerLazySingleton<ShoppingListPlanLocalDataSource>(
    () => ShoppingListPlanLocalDataSource(sl<AppDatabase>()),
  );

  // Repository
  sl.registerLazySingleton<PurchasePlanRepository>(
    () => PurchasePlanRepositoryImpl(
      local: sl<PurchasePlanLocalDataSource>(),
      shoppingListLocal: sl<ShoppingListPlanLocalDataSource>(),
      optimizerRemote: sl<OptimizerRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<RecipeRepository>(
    () => RecipeRepositoryImpl(
      remote: sl<RecipeRemoteDataSource>(),
      local: sl<RecipeLocalDataSource>(),
      purchasePlans: sl<PurchasePlanRepository>(),
    ),
  );

  await sl.allReady();
}
