import 'package:equatable/equatable.dart';

class Ingredient extends Equatable {
  final double? amount;
  final String? unit;
  final String name;

  const Ingredient({required this.name, this.amount, this.unit});

  @override
  List<Object?> get props => [amount, unit, name];
}