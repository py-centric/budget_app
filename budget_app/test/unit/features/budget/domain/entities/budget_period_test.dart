import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';

void main() {
  group('BudgetPeriod', () {
    test('should create BudgetPeriod with required fields', () {
      const period = BudgetPeriod(year: 2024, month: 1);

      expect(period.year, 2024);
      expect(period.month, 1);
    });

    test('should throw assertion error for invalid month', () {
      expect(
        () => BudgetPeriod(year: 2024, month: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should throw assertion error for month > 12', () {
      expect(
        () => BudgetPeriod(year: 2024, month: 13),
        throwsA(isA<AssertionError>()),
      );
    });

    test('previous should return previous month', () {
      const period = BudgetPeriod(year: 2024, month: 5);
      final previous = period.previous;

      expect(previous.year, 2024);
      expect(previous.month, 4);
    });

    test('previous should handle January', () {
      const period = BudgetPeriod(year: 2024, month: 1);
      final previous = period.previous;

      expect(previous.year, 2023);
      expect(previous.month, 12);
    });

    test('next should return next month', () {
      const period = BudgetPeriod(year: 2024, month: 5);
      final next = period.next;

      expect(next.year, 2024);
      expect(next.month, 6);
    });

    test('next should handle December', () {
      const period = BudgetPeriod(year: 2024, month: 12);
      final next = period.next;

      expect(next.year, 2025);
      expect(next.month, 1);
    });

    test('startDate should return first day of month', () {
      const period = BudgetPeriod(year: 2024, month: 6);
      final start = period.startDate;

      expect(start.year, 2024);
      expect(start.month, 6);
      expect(start.day, 1);
    });

    test('endDate should return last day of month', () {
      const period = BudgetPeriod(year: 2024, month: 2);
      final end = period.endDate;

      expect(end.year, 2024);
      expect(end.month, 2);
      expect(end.day, 29); // Leap year
    });

    test('endDate should return correct last day for non-leap year', () {
      const period = BudgetPeriod(year: 2023, month: 2);
      final end = period.endDate;

      expect(end.day, 28);
    });

    test('compareTo should compare by year first', () {
      const period1 = BudgetPeriod(year: 2024, month: 1);
      const period2 = BudgetPeriod(year: 2025, month: 1);

      expect(period1.compareTo(period2), -1);
      expect(period2.compareTo(period1), 1);
    });

    test('compareTo should compare by month when year is same', () {
      const period1 = BudgetPeriod(year: 2024, month: 1);
      const period2 = BudgetPeriod(year: 2024, month: 6);

      expect(period1.compareTo(period2), -1);
      expect(period2.compareTo(period1), 1);
    });

    test('compareTo should return 0 for equal periods', () {
      const period1 = BudgetPeriod(year: 2024, month: 5);
      const period2 = BudgetPeriod(year: 2024, month: 5);

      expect(period1.compareTo(period2), 0);
    });

    test('toString should format correctly', () {
      const period = BudgetPeriod(year: 2024, month: 5);

      expect(period.toString(), '2024-05');
    });

    test('toString should pad single digit month', () {
      const period = BudgetPeriod(year: 2024, month: 1);

      expect(period.toString(), '2024-01');
    });

    test('props should contain year and month', () {
      const period = BudgetPeriod(year: 2024, month: 6);

      expect(period.props, [2024, 6]);
    });

    test('two periods with same values should be equal', () {
      const period1 = BudgetPeriod(year: 2024, month: 1);
      const period2 = BudgetPeriod(year: 2024, month: 1);

      expect(period1, equals(period2));
    });

    test('two periods with different values should not be equal', () {
      const period1 = BudgetPeriod(year: 2024, month: 1);
      const period2 = BudgetPeriod(year: 2024, month: 2);

      expect(period1, isNot(equals(period2)));
    });
  });
}
