import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:budget_app/features/financial_tools/presentation/widgets/savings_chart.dart';
import 'package:budget_app/features/financial_tools/domain/entities/amortization_point.dart';

void main() {
  final schedule = [
    const AmortizationPoint(month: 0, principalPaid: 0, interestPaid: 0, remainingBalance: 10000),
    const AmortizationPoint(month: 12, principalPaid: 800, interestPaid: 200, remainingBalance: 9200),
    const AmortizationPoint(month: 24, principalPaid: 900, interestPaid: 100, remainingBalance: 8300),
    const AmortizationPoint(month: 36, principalPaid: 950, interestPaid: 50, remainingBalance: 7350),
  ];

  Widget buildChart({List<AmortizationPoint>? data}) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 300,
          child: SavingsChart(schedule: data ?? schedule),
        ),
      ),
    );
  }

  group('SavingsChart', () {
    testWidgets('renders LineChart', (tester) async {
      await tester.pumpWidget(buildChart());
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders empty SizedBox when schedule is empty', (tester) async {
      await tester.pumpWidget(buildChart(data: []));
      expect(find.byType(LineChart), findsNothing);
      expect(find.byType(SizedBox), findsNWidgets(2)); // wrapper + shrink
    });

    testWidgets('shows Months and Value axis labels', (tester) async {
      await tester.pumpWidget(buildChart());
      expect(find.text('Months'), findsOneWidget);
      expect(find.text('Value'), findsOneWidget);
    });

    testWidgets('renders with large schedule (sampling)', (tester) async {
      final largeSchedule = List.generate(120, (i) => AmortizationPoint(
        month: i, principalPaid: 100, interestPaid: 50,
        remainingBalance: 10000 - (i * 80).toDouble(),
      ));
      await tester.pumpWidget(buildChart(data: largeSchedule));
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders with single point', (tester) async {
      final single = [
        const AmortizationPoint(month: 0, principalPaid: 0, interestPaid: 0, remainingBalance: 10000),
      ];
      await tester.pumpWidget(buildChart(data: single));
      expect(find.byType(LineChart), findsOneWidget);
    });
  });
}
