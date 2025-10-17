import 'package:flutter/material.dart';
import '../../domain/entities/ingredient.dart';

class IngredientTile extends StatelessWidget {
  final Ingredient ingredient;
  const IngredientTile({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final amount = ingredient.amount;
    final unit = ingredient.unit;
    final quantity = [
      if (amount != null)
        amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toString(),
      if (unit != null && unit.isNotEmpty) unit,
    ].join(' ').trim();
    final title = [
      if (quantity.isNotEmpty) quantity,
      ingredient.name,
    ].join(' ').trim();

    return ListTile(
      title: Text(title),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
