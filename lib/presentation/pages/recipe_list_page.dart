import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injector.dart';
import '../../core/utils/currency_format.dart';
import '../../domain/entities/purchase_plan.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/purchase_plan_repository.dart';
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
              return _RecipeListTile(recipe: r);
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

class _RecipeListTile extends StatefulWidget {
  final Recipe recipe;
  const _RecipeListTile({required this.recipe});

  @override
  State<_RecipeListTile> createState() => _RecipeListTileState();
}

class _RecipeListTileState extends State<_RecipeListTile> {
  late final Future<PurchasePlan?> _planFuture;

  @override
  void initState() {
    super.initState();
    _planFuture =
        sl<PurchasePlanRepository>().getByRecipeId(widget.recipe.id);
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return FutureBuilder<PurchasePlan?>(
      future: _planFuture,
      builder: (context, snapshot) {
        final subtitle = _buildSubtitle(recipe, snapshot);
        return ListTile(
          title: Text(recipe.title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ParsedRecipePage(recipe: recipe)),
          ),
        );
      },
    );
  }

  String _buildSubtitle(Recipe recipe, AsyncSnapshot<PurchasePlan?> snapshot) {
    final base = 'Porties: ${recipe.servings}';
    if (snapshot.connectionState == ConnectionState.waiting) {
      return '$base • Laden…';
    }
    if (snapshot.hasError) {
      return '$base • Plan niet beschikbaar';
    }
    final plan = snapshot.data;
    if (plan == null) {
      return '$base • Geen plan';
    }
    return '$base • Totaal: ${formatEuro(plan.totalCostEur)}';
  }
}
