import 'package:intl/intl.dart';

final _euroFormat = NumberFormat.currency(locale: 'nl_NL', symbol: '€');

String formatEuro(num value) => _euroFormat.format(value);