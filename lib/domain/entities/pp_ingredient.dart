import 'package:equatable/equatable.dart';

class PurchasePlanIngredient extends Equatable {
  final List<String> ingredientIds;
  final double? amount;
  final String? unit;
  final String title;
  final double costEur;
  final int? packCount;

  const PurchasePlanIngredient({
    required this.title,
    required this.costEur,
    required this.ingredientIds,
    this.amount,
    this.unit,
    this.packCount,
  });

  @override
  List<Object?> get props =>
      [ingredientIds, amount, unit, title, costEur, packCount];
}
