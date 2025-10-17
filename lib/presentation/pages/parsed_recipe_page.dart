import 'package:flutter/material.dart';
import '../../core/utils/currency_format.dart';
import '../../domain/entities/recipe.dart';
import '../widgets/ingredient_tile.dart';
import '../widgets/line_item_tile.dart';

class ParsedRecipePage extends StatelessWidget {
  final Recipe recipe;
  const ParsedRecipePage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Gevonden recept')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.title, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text('Porties: ${recipe.servings}')),
                      Chip(
                        label: Text('Totale kosten: ${formatEuro(recipe.totalCostEur)}'),
                        backgroundColor: color.secondaryContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Ingrediënten', style: textTheme.titleLarge),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => IngredientTile(ingredient: recipe.ingredients[index]),
              childCount: recipe.ingredients.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Boodschappen (oplossing)', style: textTheme.titleLarge),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => LineItemTile(item: recipe.lineItems[index]),
              childCount: recipe.lineItems.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}