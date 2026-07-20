import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/domain/entities/budget_comparison.dart';

void main() {
  group('BudgetComparison', () {
    test('props are correct', () {
      const comparison = BudgetComparison(
        categoryId: 'cat-1',
        categoryName: 'Food',
        plannedAmount: 500,
        actualAmount: 450,
        year: 2024,
        month: 6,
      );
      expect(comparison.props, ['cat-1', 'Food', null, 500, 450, 2024, 6]);
    });

    test('variance calculates correctly', () {
      const comparison = BudgetComparison(
        categoryId: 'cat-1', categoryName: 'Food',
        plannedAmount: 500, actualAmount: 450, year: 2024, month: 6,
      );
      expect(comparison.variance, 50.0);
    });

    test('variancePercentage calculates correctly', () {
      const comparison = BudgetComparison(
        categoryId: 'cat-1', categoryName: 'Food',
        plannedAmount: 500, actualAmount: 450, year: 2024, month: 6,
      );
      expect(comparison.variancePercentage, 10.0);
    });

    test('variancePercentage with zero planned returns 0', () {
      const comparison = BudgetComparison(
        categoryId: 'cat-1', categoryName: 'Food',
        plannedAmount: 0, actualAmount: 0, year: 2024, month: 6,
      );
      expect(comparison.variancePercentage, 0);
    });

    test('percentageSpent calculates correctly', () {
      const comparison = BudgetComparison(
        categoryId: 'cat-1', categoryName: 'Food',
        plannedAmount: 500, actualAmount: 450, year: 2024, month: 6,
      );
      expect(comparison.percentageSpent, 90.0);
    });

    test('percentageSpent clamps to 200', () {
      const comparison = BudgetComparison(
        categoryId: 'cat-1', categoryName: 'Food',
        plannedAmount: 100, actualAmount: 500, year: 2024, month: 6,
      );
      expect(comparison.percentageSpent, 200.0);
    });

    test('isOverBudget returns true when actual > planned', () {
      const comparison = BudgetComparison(
        categoryId: 'cat-1', categoryName: 'Food',
        plannedAmount: 500, actualAmount: 600, year: 2024, month: 6,
      );
      expect(comparison.isOverBudget, isTrue);
    });

    test('isOverBudget returns false when actual <= planned', () {
      const comparison = BudgetComparison(
        categoryId: 'cat-1', categoryName: 'Food',
        plannedAmount: 500, actualAmount: 500, year: 2024, month: 6,
      );
      expect(comparison.isOverBudget, isFalse);
    });

    test('isUnderBudget returns true when actual < planned', () {
      const comparison = BudgetComparison(
        categoryId: 'cat-1', categoryName: 'Food',
        plannedAmount: 500, actualAmount: 400, year: 2024, month: 6,
      );
      expect(comparison.isUnderBudget, isTrue);
    });

    test('isUnderBudget returns false when actual >= planned', () {
      const comparison = BudgetComparison(
        categoryId: 'cat-1', categoryName: 'Food',
        plannedAmount: 500, actualAmount: 500, year: 2024, month: 6,
      );
      expect(comparison.isUnderBudget, isFalse);
    });

    test('isOnTrack returns true when <= 80% spent', () {
      const comparison = BudgetComparison(
        categoryId: 'cat-1', categoryName: 'Food',
        plannedAmount: 500, actualAmount: 400, year: 2024, month: 6,
      );
      expect(comparison.isOnTrack, isTrue);
    });

    test('isOnTrack returns false when > 80% spent', () {
      const comparison = BudgetComparison(
        categoryId: 'cat-1', categoryName: 'Food',
        plannedAmount: 500, actualAmount: 450, year: 2024, month: 6,
      );
      expect(comparison.isOnTrack, isFalse);
    });

    test('isOnTrack returns true when planned is 0', () {
      const comparison = BudgetComparison(
        categoryId: 'cat-1', categoryName: 'Food',
        plannedAmount: 0, actualAmount: 0, year: 2024, month: 6,
      );
      expect(comparison.isOnTrack, isTrue);
    });

    test('equality works', () {
      const c1 = BudgetComparison(
        categoryId: 'cat-1', categoryName: 'Food',
        plannedAmount: 500, actualAmount: 450, year: 2024, month: 6,
      );
      const c2 = BudgetComparison(
        categoryId: 'cat-1', categoryName: 'Food',
        plannedAmount: 500, actualAmount: 450, year: 2024, month: 6,
      );
      expect(c1, equals(c2));
    });
  });

  group('BudgetComparisonSummary', () {
    test('props are correct', () {
      const summary = BudgetComparisonSummary(
        totalPlanned: 1000, totalActual: 900,
        totalVariance: 100, overBudgetCount: 1,
        underBudgetCount: 3, onTrackCount: 4,
      );
      expect(summary.props, [1000, 900, 100, 1, 3, 4]);
    });

    test('overallPercentageSpent calculates correctly', () {
      const summary = BudgetComparisonSummary(
        totalPlanned: 1000, totalActual: 800,
        totalVariance: 200, overBudgetCount: 0,
        underBudgetCount: 2, onTrackCount: 2,
      );
      expect(summary.overallPercentageSpent, 80.0);
    });

    test('overallPercentageSpent with zero planned returns 0', () {
      const summary = BudgetComparisonSummary(
        totalPlanned: 0, totalActual: 0,
        totalVariance: 0, overBudgetCount: 0,
        underBudgetCount: 0, onTrackCount: 0,
      );
      expect(summary.overallPercentageSpent, 0);
    });

    test('isOverBudget returns true when totalActual > totalPlanned', () {
      const summary = BudgetComparisonSummary(
        totalPlanned: 1000, totalActual: 1100,
        totalVariance: -100, overBudgetCount: 2,
        underBudgetCount: 0, onTrackCount: 0,
      );
      expect(summary.isOverBudget, isTrue);
    });

    test('isOverBudget returns false when totalActual <= totalPlanned', () {
      const summary = BudgetComparisonSummary(
        totalPlanned: 1000, totalActual: 1000,
        totalVariance: 0, overBudgetCount: 0,
        underBudgetCount: 0, onTrackCount: 0,
      );
      expect(summary.isOverBudget, isFalse);
    });
  });
}
