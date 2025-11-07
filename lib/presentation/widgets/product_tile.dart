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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountUnit = _formatAmountUnit(item.amount, item.unit);
    final packCount = item.packCount;
    final showPackCount = packCount != null && packCount > 0;
    final packCountText = showPackCount ? '${packCount}x' : null;
    final priceText = formatEuro(item.costEur);

    final leadingParts = <String>[
      if (packCountText != null) packCountText,
      if (amountUnit.isNotEmpty) amountUnit,
      item.title,
    ];
    final leadText = leadingParts.where((part) => part.isNotEmpty).join(' ').trim();
    final displayText = leadText.isNotEmpty ? '$leadText - $priceText' : priceText;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        displayText,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
