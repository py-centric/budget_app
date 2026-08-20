import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/presentation/widgets/category_limit_dialog.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';
import 'package:budget_app/features/budget/domain/entities/category_limit.dart';

void main() {
  final categories = [
    const Category(id: 'food', name: 'Food', type: CategoryType.expense, icon: 'restaurant'),
    const Category(id: 'transport', name: 'Transport', type: CategoryType.expense, icon: 'directions_car'),
    const Category(id: 'salary', name: 'Salary', type: CategoryType.income),
  ];

  final existingLimit = CategoryLimit(
    id: 'cl-1', categoryId: 'food', amount: 500,
    period: LimitPeriod.monthly,
    createdAt: DateTime.now(), updatedAt: DateTime.now(),
  );

  Widget buildDialog({
    List<Category>? cats,
    CategoryLimit? existing,
    required Function(String, double, LimitPeriod) onSave,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => CategoryLimitDialog(
                categories: cats ?? categories,
                existingLimit: existing,
                onSave: onSave,
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  group('CategoryLimitDialog', () {
    testWidgets('shows title "Set Category Limit" for new limit', (tester) async {
      await tester.pumpWidget(buildDialog(onSave: (_, _, _) {}));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Set Category Limit'), findsOneWidget);
    });

    testWidgets('shows title "Edit Limit" for existing limit', (tester) async {
      await tester.pumpWidget(buildDialog(existing: existingLimit, onSave: (_, _, _) {}));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Edit Limit'), findsOneWidget);
    });

    testWidgets('Save button is disabled when no category selected', (tester) async {
      await tester.pumpWidget(buildDialog(onSave: (_, _, _) {}));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save'),
      );
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('Save button is enabled for existing limit with valid data', (tester) async {
      await tester.pumpWidget(buildDialog(existing: existingLimit, onSave: (_, _, _) {}));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save'),
      );
      expect(saveButton.onPressed, isNotNull);
    });

    testWidgets('Cancel closes dialog without saving', (tester) async {
      var saved = false;
      await tester.pumpWidget(buildDialog(onSave: (_, _, _) => saved = true));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(saved, isFalse);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('SegmentedButton shows Weekly and Monthly options', (tester) async {
      await tester.pumpWidget(buildDialog(onSave: (_, _, _) {}));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Monthly'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
    });

    testWidgets('only expense categories shown in dropdown', (tester) async {
      await tester.pumpWidget(buildDialog(onSave: (_, _, _) {}));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      expect(find.text('Food'), findsWidgets);
      expect(find.text('Transport'), findsWidgets);
    });

    testWidgets('pre-fills amount when editing existing limit', (tester) async {
      await tester.pumpWidget(buildDialog(existing: existingLimit, onSave: (_, _, _) {}));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('500.00'), findsOneWidget);
    });

    testWidgets('Save calls onSave and closes dialog with existing limit', (tester) async {
      String? savedCategoryId;
      double? savedAmount;

      await tester.pumpWidget(buildDialog(
        existing: existingLimit,
        onSave: (catId, amount, period) {
          savedCategoryId = catId;
          savedAmount = amount;
        },
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(savedCategoryId, 'food');
      expect(savedAmount, 500.0);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('changing amount and saving works', (tester) async {
      double? savedAmount;

      await tester.pumpWidget(buildDialog(
        existing: existingLimit,
        onSave: (_, amount, _) => savedAmount = amount,
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Clear and enter new amount
      await tester.enterText(find.byType(TextField), '750');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(savedAmount, 750.0);
    });

    testWidgets('period selection changes are reflected in save', (tester) async {
      LimitPeriod? savedPeriod;

      await tester.pumpWidget(buildDialog(
        existing: existingLimit,
        onSave: (_, _, period) => savedPeriod = period,
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap Weekly segment
      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(savedPeriod, LimitPeriod.weekly);
    });
  });
}
