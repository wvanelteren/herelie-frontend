import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/utils/currency_format.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/purchase_plan.dart';
import '../../domain/entities/pp_ingredient.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/purchase_plan_repository.dart';
import '../blocs/recipe_detail/recipe_detail_cubit.dart';
import '../blocs/recipe_detail/recipe_detail_state.dart';
import '../style/ui_symbols.dart';
import '../widgets/basic_scaffold.dart';
import '../widgets/ingredient_tile.dart';
import '../widgets/product_tile.dart';

class ParsedRecipePage extends StatefulWidget {
  final Recipe recipe;
  const ParsedRecipePage({super.key, required this.recipe});

  @override
  State<ParsedRecipePage> createState() => _ParsedRecipePageState();
}

class _ParsedRecipePageState extends State<ParsedRecipePage> {
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
    return BlocProvider.value(
      value: _cubit,
      child: BasicScaffold(
        child: BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
          builder: (context, state) {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                _TitleSection(title: widget.recipe.title),
                const SizedBox(height: 24),
                _InfoSection(state: state),
                const SizedBox(height: 24),
                _IngredientsSection(ingredients: state.scaledIngredients),
                const SizedBox(height: 24),
                _ProductsSection(state: state),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  final String title;
  const _TitleSection({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final RecipeDetailState state;
  const _InfoSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final child = state.isLoadingPlan
        ? const _InfoSkeleton(key: ValueKey('info-skeleton'))
        : _InfoContent(
            key: const ValueKey('info-content'),
            state: state,
          );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: child,
    );
  }
}

class _InfoContent extends StatelessWidget {
  final RecipeDetailState state;
  const _InfoContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priceLabel = _priceLabel();
    final cubit = context.read<RecipeDetailCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          priceLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              '${UiSymbols.servings} ${state.servings}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            _ServingsButtons(
              canDecrease: state.canDecrease,
              onDecrease: cubit.decreaseServings,
              onIncrease: cubit.increaseServings,
            ),
          ],
        ),
        if (state.planLoadFailed) ...[
          const SizedBox(height: 12),
          Text(
            'Kon aankoopplan niet laden.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  String _priceLabel() {
    if (state.planLoadFailed) return 'Onbekend';
    final plan = state.purchasePlan;
    if (plan == null) return 'Niet beschikbaar';
    return formatEuro(plan.totalCostEur);
  }
}

class _InfoSkeleton extends StatelessWidget {
  const _InfoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final color =
        Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SkeletonBlock(width: 120, height: 24, color: color),
        const SizedBox(height: 12),
        Row(
          children: [
            _SkeletonBlock(
              width: 80,
              height: 28,
              color: color,
              borderRadius: 20,
            ),
            const SizedBox(width: 12),
            _SkeletonBlock(
              width: 140,
              height: 36,
              color: color,
            ),
          ],
        ),
      ],
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color color;

  const _SkeletonBlock({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class _ServingsButtons extends StatelessWidget {
  final bool canDecrease;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _ServingsButtons({
    required this.canDecrease,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    ButtonStyle style() => TextButton.styleFrom(
          minimumSize: const Size(40, 40),
          alignment: Alignment.center,
          foregroundColor: Colors.black,
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: canDecrease ? onDecrease : null,
          style: style(),
          child: const Text('[-]'),
        ),
        TextButton(
          onPressed: onIncrease,
          style: style(),
          child: const Text('[+]'),
        ),
      ],
    );
  }
}

class _IngredientsSection extends StatelessWidget {
  final List<Ingredient> ingredients;
  const _IngredientsSection({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Ingrediënten'),
          SizedBox(height: 8),
          Text('Geen ingrediënten.'),
        ],
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < ingredients.length; i++) {
      rows.add(IngredientTile(ingredient: ingredients[i]));
      if (i != ingredients.length - 1) {
        rows.add(const Divider());
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Ingrediënten'),
        const SizedBox(height: 8),
        ...rows,
      ],
    );
  }
}

class _ProductsSection extends StatelessWidget {
  final RecipeDetailState state;
  const _ProductsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final ingredientLookup = {
      for (final ing in state.scaledIngredients)
        if (ing.id != null) ing.id!: ing,
    };

    Widget body;
    if (state.isLoadingPlan) {
      body = const Center(child: CircularProgressIndicator());
    } else if (state.planLoadFailed) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Aankoopplan kon niet geladen worden.'),
          const SizedBox(height: 8),
          TextButton(
            onPressed: context.read<RecipeDetailCubit>().refreshPlan,
            child: const Text('Opnieuw proberen'),
          ),
        ],
      );
    } else {
      final PurchasePlan? plan = state.purchasePlan;
      final items = plan?.items ?? const <PurchasePlanIngredient>[];
      if (items.isEmpty) {
        body = const Text('Geen aankoopplan beschikbaar.');
      } else {
        final rows = <Widget>[];
        for (var i = 0; i < items.length; i++) {
          final planItem = items[i];
          Ingredient? mappedIngredient;
          for (final id in planItem.ingredientIds) {
            final match = ingredientLookup[id];
            if (match != null) {
              mappedIngredient = match;
              break;
            }
          }
          rows.add(ProductTile(item: planItem, ingredient: mappedIngredient));
          if (i != items.length - 1) {
            rows.add(const Divider());
          }
        }
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Producten'),
        const SizedBox(height: 8),
        body,
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
