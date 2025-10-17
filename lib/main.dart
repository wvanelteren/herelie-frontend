import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/di/injector.dart';
import 'domain/repositories/recipe_repository.dart';
import 'presentation/blocs/process_recipe/process_recipe_cubit.dart';
import 'presentation/blocs/recipe_list/recipe_list_cubit.dart';
import 'presentation/pages/input_recipe_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupInjector();
  runApp(const RecipeApp());
}

class RecipeApp extends StatelessWidget {
  const RecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorSeed = const Color(0xFF6B8DFF); // fris blauw
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProcessRecipeCubit(sl<RecipeRepository>())),
        BlocProvider(create: (_) => RecipeListCubit(sl<RecipeRepository>())..load()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Recepten',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: colorSeed,
          textTheme: GoogleFonts.interTextTheme(),
        ),
        home: const InputRecipePage(),
      ),
    );
  }
}