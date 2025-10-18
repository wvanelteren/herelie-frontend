import 'package:flutter/material.dart';
import '../../core/utils/currency_format.dart';
import '../../domain/entities/recipe.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
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

            // Small info card: Price (only) + Porties chip, matching the clean aesthetic
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        _Metric(
                          label: 'Totale prijs',
                          value: formatEuro(widget.recipe.totalCostEur),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text('Porties: ${widget.recipe.servings}',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: cs.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              )),
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
                    setState(() => _section = set.first);
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14)),
                    side: WidgetStatePropertyAll(BorderSide(color: cs.outlineVariant)),
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
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
                firstChild: _IngredientsList(recipe: widget.recipe),
                secondChild: _ProductsList(recipe: widget.recipe),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _IngredientsList extends StatelessWidget {
  final Recipe recipe;
  const _IngredientsList({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Column(
          children: [
            _SectionHeader(
              title: 'Ingrediënten',
              count: '${recipe.ingredients.length} item${recipe.ingredients.length == 1 ? '' : 's'}',
            ),
            const Divider(height: 1),
            ListView.separated(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: recipe.ingredients.length,
              itemBuilder: (context, i) => IngredientTile(ingredient: recipe.ingredients[i]),
              separatorBuilder: (_, __) => const Divider(height: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductsList extends StatelessWidget {
  final Recipe recipe;
  const _ProductsList({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Column(
          children: [
            _SectionHeader(
              title: 'Producten',
              count: '${recipe.lineItems.length} item${recipe.lineItems.length == 1 ? '' : 's'}',
            ),
            const Divider(height: 1),
            ListView.separated(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: recipe.lineItems.length,
              itemBuilder: (context, i) {
                final ingredient = i < recipe.ingredients.length ? recipe.ingredients[i] : null;
                return ProductTile(
                  item: recipe.lineItems[i],
                  ingredient: ingredient,
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
            ),
          ],
        ),
      ),
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
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(
            count,
            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
