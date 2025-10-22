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
    final amount = ingredient.amount;
    final unit = ingredient.unit;
    final quantity = [
      if (amount != null) _formatAmount(amount),
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
