import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:budget_app/features/budget/presentation/widgets/projection_table.dart';
import 'package:budget_app/features/budget/domain/entities/projection_point.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState> implements SettingsBloc {}

void main() {
  late MockSettingsBloc mockSettingsBloc;

  setUp(() {
    mockSettingsBloc = MockSettingsBloc();
    when(() => mockSettingsBloc.state).thenReturn(const SettingsState());
  });

  testWidgets('ProjectionTable displays negative balances in red', (WidgetTester tester) async {
    final points = [
      ProjectionPoint(
        date: DateTime(2026, 3, 1),
        balance: 500.0,
        netChange: 100.0,
        actualBalance: 500.0,
        potentialBalance: 500.0,
        netChangeActual: 100.0,
        netChangePotential: 100.0,
        isWeekEnding: false,
      ),
      ProjectionPoint(
        date: DateTime(2026, 3, 2),
        balance: -50.0,
        netChange: -550.0,
        actualBalance: -50.0,
        potentialBalance: -50.0,
        netChangeActual: -550.0,
        netChangePotential: -550.0,
        isWeekEnding: false,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<SettingsBloc>.value(
            value: mockSettingsBloc,
            child: ProjectionTable(
              points: points,
              isWeekly: false,
            ),
          ),
        ),
      ),
    );

    final positiveBalanceFinder = find.text('\$500.00');
    final negativeBalanceFinder = find.text('-\$50.00');

    expect(positiveBalanceFinder, findsNWidgets(2));
    expect(negativeBalanceFinder, findsNWidgets(2));

    // Verify styles for actual balances (index 0 usually, but let's check both)
    final positiveWidgets = tester.widgetList<Text>(positiveBalanceFinder);
    final negativeWidgets = tester.widgetList<Text>(negativeBalanceFinder);

    for (final widget in positiveWidgets) {
      // styles might differ (one is italic), but color should be null or blue
      if (widget.style?.fontStyle != FontStyle.italic) {
        expect(widget.style?.color, isNull);
      }
    }
    
    for (final widget in negativeWidgets) {
      expect(widget.style?.color, Colors.red);
    }
  });
}
