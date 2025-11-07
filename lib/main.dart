import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injector.dart';
import 'core/theme/app_theme.dart';
import 'domain/repositories/purchase_plan_repository.dart';
import 'domain/repositories/recipe_repository.dart';
import 'presentation/blocs/process_recipe/process_recipe_cubit.dart';
import 'presentation/blocs/recipe_list/recipe_list_cubit.dart';
import 'presentation/pages/recipe_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupInjector();
  runApp(const RecipeApp());
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProcessRecipeCubit(
            recipes: sl<RecipeRepository>(),
            purchasePlans: sl<PurchasePlanRepository>(),
          ),
        ),
        BlocProvider(
          create: (_) => RecipeListCubit(sl<RecipeRepository>())..load(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Recepten',
        theme: AppTheme.basic(),
        home: const RecipeListPage(),
      ),
    );
  }
}
