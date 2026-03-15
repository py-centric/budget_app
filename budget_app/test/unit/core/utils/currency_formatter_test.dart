import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('should format USD correctly', () {
      final result = CurrencyFormatter.format(1234.56, currencyCode: 'USD');
      expect(result, contains('\$'));
      expect(result, contains('1,234.56'));
    });

    test('should format EUR correctly', () {
      final result = CurrencyFormatter.format(1234.56, currencyCode: 'EUR');
      expect(result, contains('€'));
      // Note: format might vary by locale (e.g. 1.234,56 vs 1,234.56)
      // simpleCurrency uses the symbol but the rest depends on the default locale.
    });

    test('should format GBP correctly', () {
      final result = CurrencyFormatter.format(1234.56, currencyCode: 'GBP');
      expect(result, contains('£'));
    });

    test('should parse valid strings correctly', () {
      expect(CurrencyFormatter.parse('1234.56'), 1234.56);
      expect(CurrencyFormatter.parse('\$1,234.56'), 1234.56);
      expect(CurrencyFormatter.parse('1234,56'), 123456); // Current logic strips commas
    });

    test('should return null for invalid strings', () {
      expect(CurrencyFormatter.parse('abc'), isNull);
    });
  });
}
