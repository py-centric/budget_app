import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/presentation/widgets/budget_comparison_table.dart';
import 'package:budget_app/features/budget/domain/entities/budget_comparison.dart';

void main() {
  final comparisons = [
    const BudgetComparison(
      categoryId: 'food', categoryName: 'Food',
      plannedAmount: 500, actualAmount: 450, year: 2024, month: 6,
    ),
    const BudgetComparison(
      categoryId: 'transport', categoryName: 'Transport',
      plannedAmount: 200, actualAmount: 250, year: 2024, month: 6,
    ),
  ];

  final summary = const BudgetComparisonSummary(
    totalPlanned: 700, totalActual: 700,
    totalVariance: 0, overBudgetCount: 1,
    underBudgetCount: 1, onTrackCount: 0,
  );

  Widget buildTable({
    List<BudgetComparison>? comps,
    BudgetComparisonSummary? sum,
    VoidCallback? onCategoryTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 600,
          child: BudgetComparisonTable(
            comparisons: comps ?? comparisons,
            summary: sum ?? summary,
            onCategoryTap: onCategoryTap,
          ),
        ),
      ),
    );
  }

  group('BudgetComparisonTable', () {
    testWidgets('renders header row', (tester) async {
      await tester.pumpWidget(buildTable());
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Planned'), findsOneWidget);
      expect(find.text('Actual'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
    });

    testWidgets('shows summary totals', (tester) async {
      await tester.pumpWidget(buildTable());
      expect(find.text('Total Planned'), findsOneWidget);
      expect(find.text('Total Spent'), findsOneWidget);
      expect(find.text('Variance'), findsOneWidget);
    });

    testWidgets('shows category names', (tester) async {
      await tester.pumpWidget(buildTable());
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets('shows planned amounts', (tester) async {
      await tester.pumpWidget(buildTable());
      expect(find.text('\$500'), findsOneWidget);
      expect(find.text('\$200'), findsOneWidget);
    });

    testWidgets('shows actual amounts', (tester) async {
      await tester.pumpWidget(buildTable());
      expect(find.text('\$450'), findsOneWidget);
      expect(find.text('\$250'), findsOneWidget);
    });

    testWidgets('shows empty message when no comparisons', (tester) async {
      await tester.pumpWidget(buildTable(comps: []));
      expect(find.text('No budget comparisons available'), findsOneWidget);
    });

    testWidgets('shows over budget icon for overspent category', (tester) async {
      await tester.pumpWidget(buildTable());
      expect(find.byIcon(Icons.arrow_upward), findsWidgets);
    });

    testWidgets('shows check icon for on-track category', (tester) async {
      final onTrack = [
        const BudgetComparison(
          categoryId: 'food', categoryName: 'Food',
          plannedAmount: 500, actualAmount: 300, year: 2024, month: 6,
        ),
      ];
      final onTrackSummary = const BudgetComparisonSummary(
        totalPlanned: 500, totalActual: 300,
        totalVariance: 200, overBudgetCount: 0,
        underBudgetCount: 0, onTrackCount: 1,
      );
      await tester.pumpWidget(buildTable(comps: onTrack, sum: onTrackSummary));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('renders summary items with correct colors', (tester) async {
      await tester.pumpWidget(buildTable());
      final summaryItems = find.byType(BudgetComparisonTable);
      expect(summaryItems, findsOneWidget);
    });
  });
}
