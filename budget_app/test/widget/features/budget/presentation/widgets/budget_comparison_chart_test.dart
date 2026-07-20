import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:budget_app/features/budget/presentation/widgets/budget_comparison_chart.dart';
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

  Widget buildChart({List<BudgetComparison>? comps}) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 300,
          child: BudgetComparisonChart(comparisons: comps ?? comparisons),
        ),
      ),
    );
  }

  group('BudgetComparisonChart', () {
    testWidgets('renders BarChart', (tester) async {
      await tester.pumpWidget(buildChart());
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('shows empty message when no comparisons', (tester) async {
      await tester.pumpWidget(buildChart(comps: []));
      expect(find.text('No budget data to display'), findsOneWidget);
    });

    testWidgets('renders with multiple comparisons', (tester) async {
      await tester.pumpWidget(buildChart());
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('renders legend', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(height: 300, child: BudgetComparisonChart(comparisons: comparisons)),
              const BudgetComparisonLegend(),
            ],
          ),
        ),
      ));
      expect(find.text('Planned'), findsOneWidget);
      expect(find.text('Under Budget'), findsOneWidget);
      expect(find.text('Over Budget'), findsOneWidget);
    });

    testWidgets('limits to 6 comparisons', (tester) async {
      final many = List.generate(10, (i) => BudgetComparison(
        categoryId: 'cat-$i', categoryName: 'Category $i',
        plannedAmount: 100 + i * 10, actualAmount: 90 + i * 10,
        year: 2024, month: 6,
      ));
      await tester.pumpWidget(buildChart(comps: many));
      expect(find.byType(BarChart), findsOneWidget);
    });
  });

  group('BudgetComparisonLegend', () {
    testWidgets('renders all legend items', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: BudgetComparisonLegend()),
      ));
      expect(find.text('Planned'), findsOneWidget);
      expect(find.text('Under Budget'), findsOneWidget);
      expect(find.text('Over Budget'), findsOneWidget);
    });
  });
}
