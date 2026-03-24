import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount, {String currencyCode = 'USD'}) {
    final format = NumberFormat.simpleCurrency(
      name: currencyCode,
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  static String getSymbol({String currencyCode = 'USD'}) {
    final format = NumberFormat.simpleCurrency(name: currencyCode);
    return format.currencySymbol;
  }

  static double? parse(String value) {
    try {
      final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(cleanValue);
    } catch (_) {
      return null;
    }
  }
}
