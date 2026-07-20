import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/savings/presentation/widgets/savings_goal_progress_bar.dart';

void main() {
  Widget buildWidget({
    double current = 500,
    double target = 1000,
    Color? progressColor,
    Color? backgroundColor,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SavingsGoalProgressBar(
          currentAmount: current,
          targetAmount: target,
          progressColor: progressColor,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }

  group('SavingsGoalProgressBar', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byType(SavingsGoalProgressBar), findsOneWidget);
    });

    testWidgets('FractionallySizedBox widthFactor is 0.5 for 50% progress', (tester) async {
      await tester.pumpWidget(buildWidget(current: 500, target: 1000));
      final sizedBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(sizedBox.widthFactor, 0.5);
    });

    testWidgets('widthFactor clamps at 1.0 when over target', (tester) async {
      await tester.pumpWidget(buildWidget(current: 1500, target: 1000));
      final sizedBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(sizedBox.widthFactor, 1.0);
    });

    testWidgets('widthFactor is 0 when target is 0', (tester) async {
      await tester.pumpWidget(buildWidget(current: 0, target: 0));
      final sizedBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(sizedBox.widthFactor, 0);
    });

    testWidgets('shows check icon when completed', (tester) async {
      await tester.pumpWidget(buildWidget(current: 1000, target: 1000));
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('hides check icon when not completed', (tester) async {
      await tester.pumpWidget(buildWidget(current: 500, target: 1000));
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('uses custom progress color', (tester) async {
      await tester.pumpWidget(buildWidget(
        current: 500, target: 1000, progressColor: Colors.purple,
      ));
      final container = tester.widget<Container>(
        find.descendant(of: find.byType(FractionallySizedBox), matching: find.byType(Container)),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });

    testWidgets('handles zero current amount', (tester) async {
      await tester.pumpWidget(buildWidget(current: 0, target: 1000));
      final sizedBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(sizedBox.widthFactor, 0);
    });
  });
}
