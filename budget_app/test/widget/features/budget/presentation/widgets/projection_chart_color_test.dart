import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:budget_app/features/budget/presentation/widgets/projection_chart.dart';
import 'package:budget_app/features/budget/domain/entities/projection_point.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState> implements SettingsBloc {}

void main() {
  late MockSettingsBloc mockSettingsBloc;

  setUp(() {
    mockSettingsBloc = MockSettingsBloc();
    when(() => mockSettingsBloc.state).thenReturn(const SettingsState());
  });

  testWidgets('ProjectionChart uses gradient for line coloring', (WidgetTester tester) async {
    final points = [
      ProjectionPoint(
        date: DateTime(2026, 3, 1),
        balance: 100.0,
        netChange: 100.0,
        actualBalance: 100.0,
        potentialBalance: 100.0,
        netChangeActual: 100.0,
        netChangePotential: 100.0,
        isWeekEnding: false,
      ),
      ProjectionPoint(
        date: DateTime(2026, 3, 2),
        balance: -50.0,
        netChange: -150.0,
        actualBalance: -50.0,
        potentialBalance: -50.0,
        netChangeActual: -150.0,
        netChangePotential: -150.0,
        isWeekEnding: false,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<SettingsBloc>.value(
            value: mockSettingsBloc,
            child: ProjectionChart(
              points: points,
              isWeekly: false,
            ),
          ),
        ),
      ),
    );

    final lineChartFinder = find.byType(LineChart);
    expect(lineChartFinder, findsOneWidget);

    final LineChart lineChartWidget = tester.widget(lineChartFinder);
    final barData = lineChartWidget.data.lineBarsData.first;

    // Verify gradient is used
    expect(barData.gradient, isNotNull);
    expect(barData.gradient?.colors.contains(Colors.red), isTrue);
    expect(barData.gradient?.colors.contains(Colors.green), isTrue);

    // Verify above/below bar data
    expect(barData.belowBarData.show, isTrue);
    expect(barData.aboveBarData.show, isTrue);
    expect(barData.belowBarData.cutOffY, 0.0);
    expect(barData.aboveBarData.cutOffY, 0.0);
  });
}
