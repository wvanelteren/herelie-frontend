import 'package:equatable/equatable.dart';

class Ingredient extends Equatable {
  final String? id;
  final String name;
  final String? foundationId;
  final String? foundationName;
  final IngredientQuantity? normalizedQuantity;
  final IngredientQuantity? originalQuantity;

  const Ingredient({
    this.id,
    required this.name,
    this.foundationId,
    this.foundationName,
    this.normalizedQuantity,
    this.originalQuantity,
  });

  double? get amount => normalizedQuantity?.amount;
  String? get unit => normalizedQuantity?.unit;

  Ingredient scale(double multiplier) => Ingredient(
        id: id,
        name: name,
        foundationId: foundationId,
        foundationName: foundationName,
        normalizedQuantity: normalizedQuantity?.scale(multiplier),
        originalQuantity: originalQuantity?.scale(multiplier),
      );

  @override
  List<Object?> get props => [
        id,
        name,
        foundationId,
        foundationName,
        normalizedQuantity,
        originalQuantity,
      ];
}

class IngredientQuantity extends Equatable {
  final double? amount;
  final String? unit;

  const IngredientQuantity({
    this.amount,
    this.unit,
  });

  IngredientQuantity scale(double multiplier) => IngredientQuantity(
        amount: amount != null ? amount! * multiplier : null,
        unit: unit,
      );

  @override
  List<Object?> get props => [amount, unit];
}
