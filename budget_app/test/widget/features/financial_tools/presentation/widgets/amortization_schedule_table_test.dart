import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/financial_tools/presentation/widgets/amortization_schedule_table.dart';
import 'package:budget_app/features/financial_tools/domain/entities/amortization_point.dart';

void main() {
  final schedule = [
    const AmortizationPoint(month: 1, principalPaid: 800, interestPaid: 200, remainingBalance: 9200),
    const AmortizationPoint(month: 2, principalPaid: 810, interestPaid: 190, remainingBalance: 8390),
    const AmortizationPoint(month: 3, principalPaid: 820, interestPaid: 180, remainingBalance: 7570),
  ];

  Widget buildTable({List<AmortizationPoint>? data, String currency = 'USD'}) {
    return MaterialApp(
      home: Scaffold(
        body: AmortizationScheduleTable(
          schedule: data ?? schedule,
          currencyCode: currency,
        ),
      ),
    );
  }

  group('AmortizationScheduleTable', () {
    testWidgets('renders DataTable', (tester) async {
      await tester.pumpWidget(buildTable());
      expect(find.byType(DataTable), findsOneWidget);
    });

    testWidgets('shows column headers', (tester) async {
      await tester.pumpWidget(buildTable());
      expect(find.text('Mo'), findsOneWidget);
      expect(find.text('Principal'), findsOneWidget);
      expect(find.text('Interest'), findsOneWidget);
      expect(find.text('Balance'), findsOneWidget);
    });

    testWidgets('renders month numbers', (tester) async {
      await tester.pumpWidget(buildTable());
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('renders with empty schedule', (tester) async {
      await tester.pumpWidget(buildTable(data: []));
      expect(find.byType(DataTable), findsOneWidget);
      expect(find.text('Mo'), findsOneWidget);
    });

    testWidgets('renders with different currency', (tester) async {
      await tester.pumpWidget(buildTable(currency: 'EUR'));
      expect(find.byType(DataTable), findsOneWidget);
    });
  });
}
