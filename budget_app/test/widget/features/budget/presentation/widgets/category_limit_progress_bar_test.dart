import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/presentation/widgets/category_limit_progress_bar.dart';

void main() {
  Widget buildWidget({
    double spent = 50,
    double limit = 100,
    double height = 8.0,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CategoryLimitProgressBar(
          spentAmount: spent,
          limitAmount: limit,
          height: height,
        ),
      ),
    );
  }

  group('CategoryLimitProgressBar', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byType(CategoryLimitProgressBar), findsOneWidget);
    });

    testWidgets('green color when under 80%', (tester) async {
      await tester.pumpWidget(buildWidget(spent: 50, limit: 100));
      final container = tester.widget<Container>(
        find.descendant(of: find.byType(FractionallySizedBox), matching: find.byType(Container)),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.green);
    });

    testWidgets('orange color when over 80%', (tester) async {
      await tester.pumpWidget(buildWidget(spent: 85, limit: 100));
      final container = tester.widget<Container>(
        find.descendant(of: find.byType(FractionallySizedBox), matching: find.byType(Container)),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.orange);
    });

    testWidgets('red color when over budget', (tester) async {
      await tester.pumpWidget(buildWidget(spent: 120, limit: 100));
      final container = tester.widget<Container>(
        find.descendant(of: find.byType(FractionallySizedBox), matching: find.byType(Container)),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red);
    });

    testWidgets('FractionallySizedBox clamps at 1.0 when over budget', (tester) async {
      await tester.pumpWidget(buildWidget(spent: 200, limit: 100));
      final sizedBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(sizedBox.widthFactor, 1.0);
    });

    testWidgets('widthFactor is 0 when limit is 0', (tester) async {
      await tester.pumpWidget(buildWidget(spent: 0, limit: 0));
      final sizedBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(sizedBox.widthFactor, 0);
    });

    testWidgets('uses custom colors when provided', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CategoryLimitProgressBar(
            spentAmount: 50,
            limitAmount: 100,
            progressColor: Colors.purple,
            backgroundColor: Colors.grey[400],
          ),
        ),
      ));
      final container = tester.widget<Container>(
        find.descendant(of: find.byType(FractionallySizedBox), matching: find.byType(Container)),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.purple);
    });

    testWidgets('custom height is applied', (tester) async {
      await tester.pumpWidget(buildWidget(height: 16));
      final outerContainer = tester.widgetList<Container>(
        find.byType(Container),
      ).first;
      expect(outerContainer.constraints?.maxHeight, 16);
    });
  });
}
