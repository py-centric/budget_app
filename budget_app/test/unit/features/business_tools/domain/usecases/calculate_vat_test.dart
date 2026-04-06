import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/business_tools/domain/usecases/calculate_vat.dart';

void main() {
  late CalculateVat calculator;

  setUp(() {
    calculator = CalculateVat();
  });

  group('CalculateVat', () {
    group('fromNet', () {
      test('should calculate VAT from net amount', () {
        final result = calculator.fromNet(100.0, 20.0);

        expect(result.netAmount, 100.0);
        expect(result.vatAmount, 20.0);
        expect(result.grossAmount, 120.0);
        expect(result.vatRate, 20.0);
      });

      test('should handle 0% VAT rate', () {
        final result = calculator.fromNet(100.0, 0.0);

        expect(result.netAmount, 100.0);
        expect(result.vatAmount, 0.0);
        expect(result.grossAmount, 100.0);
      });

      test('should handle decimal VAT rates', () {
        final result = calculator.fromNet(100.0, 17.5);

        expect(result.vatAmount, 17.5);
        expect(result.grossAmount, 117.5);
      });

      test('should handle 0 net amount', () {
        final result = calculator.fromNet(0.0, 20.0);

        expect(result.netAmount, 0.0);
        expect(result.vatAmount, 0.0);
        expect(result.grossAmount, 0.0);
      });
    });

    group('fromGross', () {
      test('should calculate VAT from gross amount', () {
        final result = calculator.fromGross(120.0, 20.0);

        expect(result.grossAmount, 120.0);
        expect(result.netAmount, closeTo(100.0, 0.01));
        expect(result.vatAmount, closeTo(20.0, 0.01));
        expect(result.vatRate, 20.0);
      });

      test('should handle 0% VAT rate', () {
        final result = calculator.fromGross(100.0, 0.0);

        expect(result.netAmount, 100.0);
        expect(result.vatAmount, 0.0);
        expect(result.grossAmount, 100.0);
      });

      test('should handle decimal VAT rates', () {
        final result = calculator.fromGross(117.5, 17.5);

        expect(result.netAmount, closeTo(100.0, 0.01));
        expect(result.vatAmount, closeTo(17.5, 0.01));
      });

      test('should handle 0 gross amount', () {
        final result = calculator.fromGross(0.0, 20.0);

        expect(result.netAmount, 0.0);
        expect(result.vatAmount, 0.0);
        expect(result.grossAmount, 0.0);
      });
    });
  });

  group('VatResult', () {
    test('should create VatResult with all fields', () {
      const result = VatResult(
        netAmount: 100.0,
        vatAmount: 20.0,
        grossAmount: 120.0,
        vatRate: 20.0,
      );

      expect(result.netAmount, 100.0);
      expect(result.vatAmount, 20.0);
      expect(result.grossAmount, 120.0);
      expect(result.vatRate, 20.0);
    });
  });
}
