import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/currency_format.dart';
import '../blocs/recipe_list/recipe_list_cubit.dart';
import '../blocs/recipe_list/recipe_list_state.dart';
import 'parsed_recipe_page.dart';
import 'input_recipe_page.dart';

class RecipeListPage extends StatelessWidget {
  const RecipeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mijn Recepten')),
      body: BlocBuilder<RecipeListCubit, RecipeListState>(
        buildWhen: (p, n) => p.status != n.status || p.recipes != n.recipes,
        builder: (context, state) {
          if (state.status == ListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ListStatus.failure) {
            return Center(child: Text(state.error ?? 'Kon recepten niet laden'));
          }
          if (state.recipes.isEmpty) {
            return const Center(child: Text('Nog geen recepten. Voeg eerst een recept toe.'));
          }
          return ListView.separated(
            itemCount: state.recipes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final r = state.recipes[i];
              return ListTile(
                title: Text(r.title),
                subtitle: Text('Porties: ${r.servings} • Totaal: ${formatEuro(r.totalCostEur)}'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ParsedRecipePage(recipe: r)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const InputRecipePage()),
        ),
        tooltip: 'Nieuw recept',
        child: const Icon(Icons.add),
      ),
    );
  }
}
