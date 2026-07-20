import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_comparison_event.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_comparison_state.dart';
import 'package:budget_app/features/budget/domain/entities/budget_comparison.dart';

void main() {
  group('BudgetComparisonEvent', () {
    test('LoadBudgetComparison props', () {
      const event = LoadBudgetComparison(budgetId: 'b1', year: 2024, month: 6);
      expect(event.props, ['b1', 2024, 6]);
    });

    test('RefreshBudgetComparison props', () {
      expect(RefreshBudgetComparison().props, isEmpty);
    });
  });

  group('BudgetComparisonState', () {
    test('BudgetComparisonInitial props', () {
      expect(BudgetComparisonInitial().props, isEmpty);
    });

    test('BudgetComparisonLoading props', () {
      expect(BudgetComparisonLoading().props, isEmpty);
    });

    test('BudgetComparisonError props', () {
      const state = BudgetComparisonError('error');
      expect(state.props, ['error']);
    });

    test('BudgetComparisonLoaded props', () {
      const comparison = BudgetComparison(
        categoryId: 'cat-1', categoryName: 'Food',
        plannedAmount: 500, actualAmount: 450, year: 2024, month: 6,
      );
      const summary = BudgetComparisonSummary(
        totalPlanned: 500, totalActual: 450,
        totalVariance: 50, overBudgetCount: 0,
        underBudgetCount: 0, onTrackCount: 1,
      );
      final state = BudgetComparisonLoaded(
        comparisons: [comparison], summary: summary,
        year: 2024, month: 6,
      );
      expect(state.props, [[comparison], summary, 2024, 6]);
    });
  });
}
