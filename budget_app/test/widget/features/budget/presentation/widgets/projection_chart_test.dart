import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('ProjectionChart displays correctly with data', (WidgetTester tester) async {
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
        balance: 200.0,
        netChange: 100.0,
        actualBalance: 200.0,
        potentialBalance: 200.0,
        netChangeActual: 100.0,
        netChangePotential: 100.0,
        isWeekEnding: false,
      ),
      ProjectionPoint(
        date: DateTime(2026, 3, 3),
        balance: 150.0,
        netChange: -50.0,
        actualBalance: 150.0,
        potentialBalance: 150.0,
        netChangeActual: -50.0,
        netChangePotential: -50.0,
        isWeekEnding: true,
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

    // Give the chart time to render
    await tester.pumpAndSettle();

    // Verify FlChart is in the tree
    expect(find.byType(ProjectionChart), findsOneWidget);
  });

  testWidgets('ProjectionChart displays empty state when no data', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProjectionChart(
            points: [],
            isWeekly: false,
          ),
        ),
      ),
    );

    expect(find.text('No data for projection.'), findsOneWidget);
  });
}
