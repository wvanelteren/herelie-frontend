import 'package:flutter/material.dart';
import '../../core/utils/currency_format.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/pp_ingredient.dart';

class ProductTile extends StatelessWidget {
  final PurchasePlanIngredient item;
  final Ingredient? ingredient;

  const ProductTile({super.key, required this.item, this.ingredient});

  String _formatAmountUnit(double? amount, String? unit) {
    final a = amount;
    final u = unit ?? '';
    if (a == null && u.isEmpty) return '';
    final numStr = a == null
        ? ''
        : (a % 1 == 0 ? a.toStringAsFixed(0) : a.toString());
    return [numStr, u].where((s) => s.isNotEmpty).join(' ').trim();
  }

  String _ingredientDisplay() {
    if (ingredient == null) return '';
    final displayedQuantity =ingredient!.originalQuantity;
    final quantity = _formatAmountUnit(
      displayedQuantity?.amount,
      displayedQuantity?.unit,
    );
    return [
      quantity,
      ingredient!.name,
    ].where((s) => s.isNotEmpty).join(' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountUnit = _formatAmountUnit(item.amount, item.unit);
    final ingredientDescription = _ingredientDisplay();
    final packCount = item.packCount;
    final showPackCount = packCount != null && packCount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title (brand + product name)
          Text(
            item.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          // Price + amount/unit on one row
          Row(
            children: [
              Text(
                formatEuro(item.costEur),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              if (amountUnit.isNotEmpty) ...[
                const SizedBox(width: 12),
                Text(
                  amountUnit,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (showPackCount) ...[
                const Spacer(),
                Text(
                  'x$packCount',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          if (ingredientDescription.isNotEmpty || amountUnit.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'voor ${ingredientDescription.isNotEmpty ? ingredientDescription : amountUnit}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
