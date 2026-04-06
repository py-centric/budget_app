import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/financial_tools/domain/usecases/convert_rate.dart';

void main() {
  late RateConverter converter;

  setUp(() {
    converter = RateConverter();
  });

  group('RateConverter', () {
    test('simpleToCompound should convert 10% simple to compound', () {
      final result = converter.simpleToCompound(
        simpleRate: 10.0,
        compoundingPeriodsPerYear: 12,
      );

      expect(result, closeTo(10.47, 0.01));
    });

    test('simpleToCompound should handle monthly compounding', () {
      final result = converter.simpleToCompound(
        simpleRate: 12.0,
        compoundingPeriodsPerYear: 12,
      );

      expect(result, closeTo(12.68, 0.01));
    });

    test('simpleToCompound should handle daily compounding', () {
      final result = converter.simpleToCompound(
        simpleRate: 10.0,
        compoundingPeriodsPerYear: 365,
      );

      expect(result, closeTo(10.52, 0.01));
    });

    test('simpleToCompound should return 0 for 0% rate', () {
      final result = converter.simpleToCompound(simpleRate: 0.0);

      expect(result, 0.0);
    });

    test('compoundToSimple should convert compound to simple', () {
      final result = converter.compoundToSimple(
        compoundRate: 10.0,
        compoundingPeriodsPerYear: 12,
      );

      expect(result, closeTo(9.57, 0.01));
    });

    test('compoundToSimple should handle monthly compounding', () {
      final result = converter.compoundToSimple(
        compoundRate: 12.0,
        compoundingPeriodsPerYear: 12,
      );

      expect(result, closeTo(11.39, 0.01));
    });

    test('compoundToSimple should return 0 for 0% rate', () {
      final result = converter.compoundToSimple(compoundRate: 0.0);

      expect(result, 0.0);
    });

    test('calculateSimpleInterestTotal should calculate correct total', () {
      final result = converter.calculateSimpleInterestTotal(
        principal: 1000.0,
        annualRate: 10.0,
        years: 1.0,
      );

      expect(result, 100.0);
    });

    test(
      'calculateSimpleInterestTotal should calculate multi-year interest',
      () {
        final result = converter.calculateSimpleInterestTotal(
          principal: 1000.0,
          annualRate: 10.0,
          years: 3.0,
        );

        expect(result, 300.0);
      },
    );

    test('calculateSimpleInterestTotal should handle decimal years', () {
      final result = converter.calculateSimpleInterestTotal(
        principal: 1000.0,
        annualRate: 10.0,
        years: 0.5,
      );

      expect(result, 50.0);
    });

    test('calculateSimpleInterestTotal should return 0 for 0 principal', () {
      final result = converter.calculateSimpleInterestTotal(
        principal: 0.0,
        annualRate: 10.0,
        years: 1.0,
      );

      expect(result, 0.0);
    });
  });
}
