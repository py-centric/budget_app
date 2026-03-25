import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount, {String currencyCode = 'USD'}) {
    final decimalPlaces = getDecimalPlaces(currencyCode: currencyCode);
    final format = NumberFormat.simpleCurrency(
      name: currencyCode,
      decimalDigits: decimalPlaces,
    );
    return format.format(amount);
  }

  static String getSymbol({String currencyCode = 'USD'}) {
    final format = NumberFormat.simpleCurrency(name: currencyCode);
    return format.currencySymbol;
  }

  static int getDecimalPlaces({String currencyCode = 'USD'}) {
    final noDecimalCurrencies = ['JPY', 'KRW'];
    return noDecimalCurrencies.contains(currencyCode.toUpperCase()) ? 0 : 2;
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
