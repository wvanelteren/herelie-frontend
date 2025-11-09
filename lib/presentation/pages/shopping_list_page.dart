import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/currency_format.dart';
import '../../domain/entities/purchase_plan.dart';
import '../../domain/entities/recipe.dart';
import '../blocs/shopping_list/shopping_list_cubit.dart';
import '../blocs/shopping_list/shopping_list_state.dart';
import '../navigation/tab_navigation.dart';
import '../widgets/app_bottom_bar.dart';
import '../widgets/basic_scaffold.dart';
import '../widgets/product_tile.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeGenerate());
  }

  void _maybeGenerate() {
    final cubit = context.read<ShoppingListCubit>();
    final state = cubit.state;
    if (state.hasSelection &&
        state.combinedPlan == null &&
        !state.isGenerating) {
      cubit.generateCombinedPlan();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShoppingListCubit, ShoppingListState>(
      listenWhen: (prev, next) => prev.selectedRecipes != next.selectedRecipes,
      listener: (_, state) {
        if (state.hasSelection &&
            state.combinedPlan == null &&
            !state.isGenerating) {
          context.read<ShoppingListCubit>().generateCombinedPlan();
        }
      },
      child: BlocBuilder<ShoppingListCubit, ShoppingListState>(
        builder: (context, state) {
          final hasSelection = state.hasSelection;
          final actions = hasSelection
              ? <Widget>[
                  if (state.combinedPlan != null)
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Opnieuw berekenen',
                      onPressed: state.isGenerating
                          ? null
                          : () => context
                                .read<ShoppingListCubit>()
                                .generateCombinedPlan(force: true),
                    ),
                  TextButton(
                    onPressed: state.isGenerating
                        ? null
                        : () => context.read<ShoppingListCubit>().clear(),
                    child: const Text('Lijst leegmaken'),
                  ),
                ]
              : null;

          return BasicScaffold(
            actions: actions,
            bottomNavigationBar: AppBottomBar(
              currentTab: AppTab.shopping,
              onTabSelected: (tab) {
                if (tab == AppTab.shopping) return;
                navigateToTab(context, tab);
              },
            ),
            child: _ShoppingListBody(state: state),
          );
        },
      ),
    );
  }
}

class _ShoppingListBody extends StatelessWidget {
  final ShoppingListState state;
  const _ShoppingListBody({required this.state});

  @override
  Widget build(BuildContext context) {
    if (!state.hasSelection) {
      return const _EmptySelectionMessage();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SelectedRecipesChips(recipes: state.selectedRecipes.values),
        const SizedBox(height: 16),
        if (state.isGenerating) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 12),
        ],
        if (state.error != null) ...[
          _InlineError(message: state.error!),
          const SizedBox(height: 12),
        ],
        Expanded(
          child: state.combinedPlan == null
              ? _AwaitingGenerationMessage(
                  isGenerating: state.isGenerating,
                  onGenerate: () => context
                      .read<ShoppingListCubit>()
                      .generateCombinedPlan(force: true),
                )
              : _CombinedPlanView(plan: state.combinedPlan!),
        ),
      ],
    );
  }
}

class _SelectedRecipesChips extends StatelessWidget {
  final Iterable<Recipe> recipes;
  const _SelectedRecipesChips({required this.recipes});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ShoppingListCubit>();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: recipes
          .map(
            (recipe) => InputChip(
              label: Text(recipe.title),
              onDeleted: cubit.state.pendingRecipeIds.contains(recipe.id)
                  ? null
                  : () => cubit.toggleRecipe(recipe),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _CombinedPlanView extends StatelessWidget {
  final PurchasePlan plan;
  const _CombinedPlanView({required this.plan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: plan.items.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final item = plan.items[index];
              return ProductTile(item: item);
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Totaal: ${formatEuro(plan.totalCostEur)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AwaitingGenerationMessage extends StatelessWidget {
  final bool isGenerating;
  final VoidCallback onGenerate;

  const _AwaitingGenerationMessage({
    required this.isGenerating,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Nog geen boodschappenlijst berekend.',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: isGenerating ? null : onGenerate,
            child: const Text('Bereken lijst'),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.1),
      ),
      child: Text(message, style: TextStyle(color: color)),
    );
  }
}

class _EmptySelectionMessage extends StatelessWidget {
  const _EmptySelectionMessage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.playlist_add, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Nog geen geselecteerde recepten',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ga naar de receptenlijst en tik op het plusje om recepten aan je boodschappenlijst toe te voegen.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
