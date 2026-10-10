import 'package:intl/intl.dart';

/// Formateador monetario centralizado y reutilizable para Docentia.
/// Cumple estrictamente con el formato: $#,##0.00
///
/// Ejemplos:
///   850       → $850.00
///   4500      → $4,500.00
///   100450    → $100,450.00
///   1250000   → $1,250,000.00
///   0 / null  → $0.00
final NumberFormat _currencyNumberFormat = NumberFormat('#,##0.00', 'en_US');

String formatCurrency(num? amount) {
  if (amount == null) {
    return '\$0.00';
  }
  if (amount < 0) {
    return '-\$${_currencyNumberFormat.format(amount.abs())}';
  }
  return '\$${_currencyNumberFormat.format(amount)}';
}
