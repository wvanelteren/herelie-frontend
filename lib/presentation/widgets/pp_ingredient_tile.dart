import 'package:flutter/material.dart';
import '../../core/utils/currency_format.dart';
import '../../domain/entities/pp_ingredient.dart';

class PpIngredientTile extends StatelessWidget {
  final PurchasePlanIngredient item;
  const PpIngredientTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final amount = item.amount;
    final unit = item.unit;
    final quantity = [
      if (amount != null)
        amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toString(),
      if (unit != null && unit.isNotEmpty) unit,
    ].join(' ').trim();
    final title = [
      if (quantity.isNotEmpty) quantity,
      item.title,
    ].join(' ').trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatEuro(item.costEur),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
