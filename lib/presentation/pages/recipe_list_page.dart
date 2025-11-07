import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injector.dart';
import '../../core/utils/currency_format.dart';
import '../../domain/entities/purchase_plan.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/purchase_plan_repository.dart';
import '../blocs/recipe_list/recipe_list_cubit.dart';
import '../blocs/recipe_list/recipe_list_state.dart';
import '../style/ui_symbols.dart';
import '../widgets/basic_button.dart';
import '../widgets/basic_scaffold.dart';
import 'input_recipe_page.dart';
import 'parsed_recipe_page.dart';

class RecipeListPage extends StatelessWidget {
  const RecipeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeListCubit, RecipeListState>(
      buildWhen: (p, n) => p.status != n.status || p.recipes != n.recipes,
      builder: (context, state) {
        return BasicScaffold(
          bottomArea: BasicButton(
            label: 'Nieuw recept',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const InputRecipePage()),
            ),
          ),
          child: _RecipeListBody(state: state),
        );
      },
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
    final recipe = widget.recipe;
    final servings = recipe.servings > 0 ? recipe.servings : 1;
    _planFuture = sl<PurchasePlanRepository>().getByRecipeAndServings(
      recipe.id,
      servings,
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return FutureBuilder<PurchasePlan?>(
      future: _planFuture,
      builder: (context, snapshot) {
        final subtitle = _buildSubtitle(recipe, snapshot);
        final theme = Theme.of(context);
        return TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ParsedRecipePage(recipe: recipe)),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.centerLeft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }

  String _buildSubtitle(Recipe recipe, AsyncSnapshot<PurchasePlan?> snapshot) {
    final base = '${UiSymbols.servings} ${recipe.servings}';
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
    return '$base • ${formatEuro(plan.totalCostEur)}';
  }
}

class _RecipeListBody extends StatelessWidget {
  final RecipeListState state;
  const _RecipeListBody({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.status == ListStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == ListStatus.failure) {
      return Center(
        child: Text(state.error ?? 'Kon recepten niet laden'),
      );
    }
    if (state.recipes.isEmpty) {
      return const Center(
        child: Text('Nog geen recepten. Voeg eerst een recept toe.'),
      );
    }
    return ListView.separated(
      itemCount: state.recipes.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final recipe = state.recipes[i];
        return _RecipeListTile(recipe: recipe);
      },
    );
  }
}
