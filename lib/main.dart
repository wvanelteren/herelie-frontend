import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/di/injector.dart';
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
    // Mint‑green, soft surfaces, Poppins typography
    const mintSeed = Color(0xFF6FCF97);
    const softBg = Color(0xFFF2F7F4);

    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: mintSeed,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProcessRecipeCubit(sl<RecipeRepository>())),
        BlocProvider(create: (_) => RecipeListCubit(sl<RecipeRepository>())..load()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Recepten',
        theme: base.copyWith(
          scaffoldBackgroundColor: softBg,
          textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
          cardTheme: CardThemeData(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          appBarTheme: base.appBarTheme.copyWith(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Colors.transparent,
          ),
          listTileTheme: const ListTileThemeData(
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            dense: true,
          ),
        ),
        home: const RecipeListPage(),
      ),
    );
  }
}
