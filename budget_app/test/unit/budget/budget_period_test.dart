import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';

void main() {
  group('BudgetPeriod', () {
    test('should correctly identify leap year end date for February', () {
      final leapYearPeriod = BudgetPeriod(year: 2024, month: 2);
      final endDate = leapYearPeriod.endDate;
      expect(endDate.day, equals(29));
      expect(endDate.month, equals(2));
      expect(endDate.year, equals(2024));
    });

    test('should correctly identify non-leap year end date for February', () {
      final nonLeapYearPeriod = BudgetPeriod(year: 2023, month: 2);
      final endDate = nonLeapYearPeriod.endDate;
      expect(endDate.day, equals(28));
    });

    test('should return previous month correctly', () {
      final period = BudgetPeriod(year: 2024, month: 3);
      expect(period.previous, equals(const BudgetPeriod(year: 2024, month: 2)));
    });

    test('should return previous month correctly across years', () {
      final period = BudgetPeriod(year: 2024, month: 1);
      expect(period.previous, equals(const BudgetPeriod(year: 2023, month: 12)));
    });

    test('should return next month correctly', () {
      final period = BudgetPeriod(year: 2024, month: 11);
      expect(period.next, equals(const BudgetPeriod(year: 2024, month: 12)));
    });

    test('should return next month correctly across years', () {
      final period = BudgetPeriod(year: 2024, month: 12);
      expect(period.next, equals(const BudgetPeriod(year: 2025, month: 1)));
    });
    
    test('should sort properly', () {
      final p1 = BudgetPeriod(year: 2023, month: 12);
      final p2 = BudgetPeriod(year: 2024, month: 1);
      final p3 = BudgetPeriod(year: 2024, month: 2);
      
      final list = [p2, p3, p1];
      list.sort((a, b) => a.compareTo(b));
      
      expect(list, equals([p1, p2, p3]));
    });
  });
}
