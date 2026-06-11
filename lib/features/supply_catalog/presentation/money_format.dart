import 'package:intl/intl.dart';

/// Formats minor units + ISO currency to a localized string, e.g.
/// `(400, 'usd')` → `$4.00`. Falls back to a plain amount + code.
String formatMoney(int cents, String currency) {
  try {
    return NumberFormat.simpleCurrency(name: currency.toUpperCase())
        .format(cents / 100);
  } catch (_) {
    return '${(cents / 100).toStringAsFixed(2)} ${currency.toUpperCase()}';
  }
}
