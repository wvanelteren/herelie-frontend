import 'package:equatable/equatable.dart';

class Ingredient extends Equatable {
  final String? id;
  final double? amount;
  final String? unit;
  final String name;

  const Ingredient({this.id, required this.name, this.amount, this.unit});

  @override
  List<Object?> get props => [id, amount, unit, name];
}
