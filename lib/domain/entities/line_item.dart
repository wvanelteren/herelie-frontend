import 'package:equatable/equatable.dart';

class LineItem extends Equatable {
  final double? amount;
  final String? unit;
  final String title;
  final double lineCostEur;

  const LineItem({
    required this.title,
    required this.lineCostEur,
    this.amount,
    this.unit,
  });

  @override
  List<Object?> get props => [amount, unit, title, lineCostEur];
}