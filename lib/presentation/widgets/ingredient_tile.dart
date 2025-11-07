import 'package:flutter/material.dart';
import '../../domain/entities/ingredient.dart';

class IngredientTile extends StatelessWidget {
  final Ingredient ingredient;
  const IngredientTile({super.key, required this.ingredient});

  String _formatAmount(double value) {
    if (value % 1 == 0) return value.toStringAsFixed(0);
    final fixed = value.toStringAsFixed(2);
    return fixed.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final displayedQuantity = ingredient.originalQuantity;
    final amount = displayedQuantity?.amount;
    final unit = displayedQuantity?.unit;
    final quantityText = [
      if (amount != null) _formatAmount(amount),
      if (unit != null && unit.isNotEmpty) unit,
    ].join(' ').trim();
    final title = [
      if (quantityText.isNotEmpty) quantityText,
      ingredient.name,
    ].join(' ').trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
