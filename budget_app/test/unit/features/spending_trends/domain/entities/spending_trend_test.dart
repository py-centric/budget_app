import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/spending_trends/domain/entities/spending_trend.dart';

void main() {
  group('MonthlySpending', () {
    test('props are correct', () {
      const ms = MonthlySpending(year: 2024, month: 6, amount: 500);
      expect(ms.props, [2024, 6, 500]);
    });

    test('equality works', () {
      const ms1 = MonthlySpending(year: 2024, month: 6, amount: 500);
      const ms2 = MonthlySpending(year: 2024, month: 6, amount: 500);
      expect(ms1, equals(ms2));
    });

    test('inequality with different amount', () {
      const ms1 = MonthlySpending(year: 2024, month: 6, amount: 500);
      const ms2 = MonthlySpending(year: 2024, month: 6, amount: 600);
      expect(ms1, isNot(equals(ms2)));
    });
  });

  group('SpendingTrend', () {
    const trend = SpendingTrend(
      categoryId: 'cat-1',
      categoryName: 'Food',
      monthlyData: [
        MonthlySpending(year: 2024, month: 1, amount: 400),
        MonthlySpending(year: 2024, month: 2, amount: 450),
        MonthlySpending(year: 2024, month: 3, amount: 500),
      ],
      averageMonthly: 450,
      trendPercentage: 12.5,
    );

    test('props are correct', () {
      expect(trend.props, [
        'cat-1', 'Food', trend.monthlyData, 450, 12.5,
      ]);
    });

    test('equality works', () {
      const trend2 = SpendingTrend(
        categoryId: 'cat-1', categoryName: 'Food',
        monthlyData: [
          MonthlySpending(year: 2024, month: 1, amount: 400),
          MonthlySpending(year: 2024, month: 2, amount: 450),
          MonthlySpending(year: 2024, month: 3, amount: 500),
        ],
        averageMonthly: 450, trendPercentage: 12.5,
      );
      expect(trend, equals(trend2));
    });

    test('empty monthlyData', () {
      const empty = SpendingTrend(
        categoryId: 'cat-1', categoryName: 'Food',
        monthlyData: [], averageMonthly: 0, trendPercentage: 0,
      );
      expect(empty.monthlyData, isEmpty);
      expect(empty.averageMonthly, 0);
    });
  });
}
