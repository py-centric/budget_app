import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/shared/currencies.dart';

void main() {
  group('Currencies', () {
    test('should return all currencies when query is empty', () {
      final result = Currencies.search('');
      expect(result.length, 20);
    });

    test('should filter by currency code', () {
      final result = Currencies.search('USD');
      expect(result.any((c) => c.code == 'USD'), true);
    });

    test('should filter by currency name', () {
      final result = Currencies.search('Dollar');
      // USD, CAD, AUD, SGD, HKD, NZD all contain "Dollar"
      expect(result.length, greaterThan(0));
    });

    test('should be case insensitive', () {
      final result1 = Currencies.search('usd');
      final result2 = Currencies.search('USD');

      expect(result1.length, result2.length);
      expect(result1.first.code, 'USD');
    });

    test('should return empty for unknown currency', () {
      final result = Currencies.search('XYZ');
      expect(result.isEmpty, true);
    });

    test('should return all currencies for partial match', () {
      final result = Currencies.search('Krona');
      expect(result.isNotEmpty, true);
    });
  });

  group('Currency', () {
    test('should have correct properties', () {
      final currency = Currencies.all.first;
      expect(currency.code, isNotEmpty);
      expect(currency.name, isNotEmpty);
      expect(currency.symbol, isNotEmpty);
    });
  });
}
