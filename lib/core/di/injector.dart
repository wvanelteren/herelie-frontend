import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../db/app_database.dart';
import '../network/dio_client.dart';
import '../../data/datasources/recipe_local_data_source.dart';
import '../../data/datasources/recipe_remote_data_source.dart';
import '../../data/repositories/recipe_repository_impl.dart';
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
  sl.registerLazySingleton<RecipeLocalDataSource>(
    () => RecipeLocalDataSource(sl<AppDatabase>()),
  );

  // Repository
  sl.registerLazySingleton<RecipeRepository>(
    () => RecipeRepositoryImpl(
      remote: sl<RecipeRemoteDataSource>(),
      local: sl<RecipeLocalDataSource>(),
    ),
  );

  // Wachten tot async singletons klaar zijn (DB).
  await sl.allReady();
}