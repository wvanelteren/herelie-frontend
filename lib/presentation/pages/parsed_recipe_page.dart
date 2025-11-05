import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injector.dart';
import '../../core/utils/currency_format.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/purchase_plan.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/purchase_plan_repository.dart';
import '../blocs/recipe_detail/recipe_detail_cubit.dart';
import '../blocs/recipe_detail/recipe_detail_state.dart';
import '../widgets/ingredient_tile.dart';
import '../widgets/product_tile.dart';

enum DetailSection { ingredients, products }

class ParsedRecipePage extends StatefulWidget {
  final Recipe recipe;
  const ParsedRecipePage({super.key, required this.recipe});

  @override
  State<ParsedRecipePage> createState() => _ParsedRecipePageState();
}

class _ParsedRecipePageState extends State<ParsedRecipePage> {
  DetailSection _section = DetailSection.ingredients;
  late final RecipeDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = RecipeDetailCubit(
      recipe: widget.recipe,
      purchasePlans: sl<PurchasePlanRepository>(),
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<RecipeDetailCubit, RecipeDetailState>(
        listenWhen: (previous, current) =>
            previous.needsPlanRefresh != current.needsPlanRefresh ||
            previous.servings != current.servings,
        listener: (context, state) {
          if (_section == DetailSection.products &&
              state.needsPlanRefresh &&
              !state.planLoadFailed &&
              !state.isLoadingPlan) {
            context.read<RecipeDetailCubit>().loadProductsIfNeeded();
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Recept')),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.surfaceContainerHighest,
                  theme.scaffoldBackgroundColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: CustomScrollView(
              slivers: [
                // Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text(
                      widget.recipe.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Small info card: Price + servings controls
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
                              buildWhen: (previous, current) =>
                                  previous.purchasePlan !=
                                      current.purchasePlan ||
                                  previous.isLoadingPlan !=
                                      current.isLoadingPlan ||
                                  previous.planLoadFailed !=
                                      current.planLoadFailed ||
                                  previous.needsPlanRefresh !=
                                      current.needsPlanRefresh,
                              builder: (context, state) {
                                final label = 'Totale prijs';
                                if (state.planLoadFailed) {
                                  return _Metric(
                                    label: label,
                                    value: 'Onbekend',
                                    subtitle: 'Kon plan niet laden',
                                  );
                                }
                                if (state.isLoadingPlan) {
                                  return _Metric(label: label, value: 'Laden…');
                                }
                                if (state.needsPlanRefresh) {
                                  return _Metric(
                                    label: label,
                                    value: 'Bijwerken…',
                                  );
                                }
                                final plan = state.purchasePlan;
                                return _Metric(
                                  label: label,
                                  value: plan != null
                                      ? formatEuro(plan.totalCostEur)
                                      : 'Niet beschikbaar',
                                );
                              },
                            ),
                            const Spacer(),
                            BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
                              buildWhen: (previous, current) =>
                                  previous.servings != current.servings,
                              builder: (context, state) {
                                return _ServingsControl(
                                  servings: state.servings,
                                  canDecrease: state.canDecrease,
                                  onDecrease: context
                                      .read<RecipeDetailCubit>()
                                      .decreaseServings,
                                  onIncrease: context
                                      .read<RecipeDetailCubit>()
                                      .increaseServings,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Segmented toggle to swap at the same vertical position
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: SegmentedButton<DetailSection>(
                      segments: const [
                        ButtonSegment(
                          value: DetailSection.ingredients,
                          label: Text('Ingrediënten'),
                          icon: Icon(Icons.list_alt_rounded),
                        ),
                        ButtonSegment(
                          value: DetailSection.products,
                          label: Text('Producten'),
                          icon: Icon(Icons.shopping_bag_rounded),
                        ),
                      ],
                      selected: {_section},
                      showSelectedIcon: false,
                      onSelectionChanged: (set) {
                        final selected = set.first;
                        setState(() => _section = selected);
                        if (selected == DetailSection.products) {
                          _cubit.loadProductsIfNeeded();
                        }
                      },
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 14),
                        ),
                        side: WidgetStatePropertyAll(
                          BorderSide(color: cs.outlineVariant),
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Swappable content area (same vertical slot) with a soft cross-fade
                SliverToBoxAdapter(
                  child: AnimatedCrossFade(
                    duration: const Duration(milliseconds: 220),
                    crossFadeState: _section == DetailSection.ingredients
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: const _IngredientsList(),
                    secondChild: const _ProductsList(),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IngredientsList extends StatelessWidget {
  const _IngredientsList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
      buildWhen: (previous, current) =>
          previous.scaledIngredients != current.scaledIngredients,
      builder: (context, state) {
        final ingredients = state.scaledIngredients;
        return Card(
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Column(
              children: [
                _SectionHeader(
                  title: 'Ingrediënten',
                  count:
                      '${ingredients.length} item${ingredients.length == 1 ? '' : 's'}',
                ),
                const Divider(height: 1),
                ListView.separated(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: ingredients.length,
                  itemBuilder: (context, i) =>
                      IngredientTile(ingredient: ingredients[i]),
                  separatorBuilder: (_, __) => const Divider(height: 1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProductsList extends StatelessWidget {
  const _ProductsList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
      buildWhen: (previous, current) =>
          previous.purchasePlan != current.purchasePlan ||
          previous.isLoadingPlan != current.isLoadingPlan ||
          previous.planLoadFailed != current.planLoadFailed ||
          previous.recipe != current.recipe ||
          previous.needsPlanRefresh != current.needsPlanRefresh ||
          previous.scaledIngredients != current.scaledIngredients,
      builder: (context, state) {
        final ingredientLookup = {
          for (final ing in state.scaledIngredients)
            if (ing.id != null) ing.id!: ing,
        };

        final bool loading = state.isLoadingPlan;
        final bool failed = state.planLoadFailed;
        final bool pendingRefresh =
            state.needsPlanRefresh && !loading && !failed;
        final PurchasePlan? plan = state.purchasePlan;

        String countLabel;
        Widget body;

        if (loading || pendingRefresh) {
          countLabel = 'laden…';
          body = const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (failed) {
          countLabel = '—';
          body = Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'We konden het aankoopplan niet laden.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: context.read<RecipeDetailCubit>().refreshPlan,
                  child: const Text('Opnieuw proberen'),
                ),
              ],
            ),
          );
        } else if (plan == null || plan.items.isEmpty) {
          countLabel = '0 items';
          body = const Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Text(
              'Geen aankoopplan beschikbaar voor dit recept.',
              textAlign: TextAlign.center,
            ),
          );
        } else {
          countLabel =
              '${plan.items.length} item${plan.items.length == 1 ? '' : 's'}';
          body = ListView.separated(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: plan.items.length,
            itemBuilder: (context, i) {
              final planItem = plan.items[i];
              Ingredient? mappedIngredient;
              for (final id in planItem.ingredientIds) {
                final match = ingredientLookup[id];
                if (match != null) {
                  mappedIngredient = match;
                  break;
                }
              }
              return ProductTile(item: planItem, ingredient: mappedIngredient);
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
          );
        }

        return Card(
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Column(
              children: [
                _SectionHeader(title: 'Producten', count: countLabel),
                const Divider(height: 1),
                body,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            count,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  const _Metric({required this.label, required this.value, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _ServingsControl extends StatelessWidget {
  final int servings;
  final bool canDecrease;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _ServingsControl({
    required this.servings,
    required this.canDecrease,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: canDecrease ? onDecrease : null,
            icon: const Icon(Icons.remove_rounded),
            visualDensity: VisualDensity.compact,
            tooltip: 'Minder porties',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              'Porties: $servings',
              style: theme.textTheme.labelLarge?.copyWith(
                color: cs.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: onIncrease,
            icon: const Icon(Icons.add_rounded),
            visualDensity: VisualDensity.compact,
            tooltip: 'Meer porties',
          ),
        ],
      ),
    );
  }
}
