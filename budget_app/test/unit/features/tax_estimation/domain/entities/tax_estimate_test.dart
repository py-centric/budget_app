import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/tax_estimation/domain/entities/tax_estimate.dart';

void main() {
  group('TaxEstimate', () {
    final estimate = TaxEstimate(
      income: 100000,
      deductions: 13850,
      taxableIncome: 86150,
      effectiveRate: 18.0,
      totalTax: 15507,
      takeHome: 84493,
    );

    test('props are correct', () {
      expect(estimate.props, [100000, 13850, 86150, 18.0, 15507, 84493]);
    });

    test('equality works', () {
      final estimate2 = TaxEstimate(
        income: 100000, deductions: 13850, taxableIncome: 86150,
        effectiveRate: 18.0, totalTax: 15507, takeHome: 84493,
      );
      expect(estimate, equals(estimate2));
    });

    test('inequality with different income', () {
      final estimate2 = TaxEstimate(
        income: 120000, deductions: 13850, taxableIncome: 106150,
        effectiveRate: 20.0, totalTax: 21000, takeHome: 99000,
      );
      expect(estimate, isNot(equals(estimate2)));
    });

    test('toMap serializes correctly', () {
      final map = estimate.toMap();
      expect(map['income'], 100000);
      expect(map['deductions'], 13850);
      expect(map['taxable_income'], 86150);
      expect(map['effective_rate'], 18.0);
      expect(map['total_tax'], 15507);
      expect(map['take_home'], 84493);
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'income': 100000, 'deductions': 13850, 'taxable_income': 86150,
        'effective_rate': 18.0, 'total_tax': 15507, 'take_home': 84493,
      };
      final result = TaxEstimate.fromMap(map);
      expect(result.income, 100000);
      expect(result.totalTax, 15507);
      expect(result.takeHome, 84493);
    });

    test('fromMap with zero values', () {
      final map = {
        'income': 0, 'deductions': 0, 'taxable_income': 0,
        'effective_rate': 0, 'total_tax': 0, 'take_home': 0,
      };
      final result = TaxEstimate.fromMap(map);
      expect(result.income, 0);
    });
  });
}
