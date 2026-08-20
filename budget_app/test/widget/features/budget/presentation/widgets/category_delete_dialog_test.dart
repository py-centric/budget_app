import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/presentation/widgets/category_delete_dialog.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';

void main() {
  const foodCategory = Category(id: 'food', name: 'Food', type: CategoryType.expense);
  final availableCategories = [
    const Category(id: 'transport', name: 'Transport', type: CategoryType.expense),
    const Category(id: 'entertainment', name: 'Entertainment', type: CategoryType.expense),
  ];

  Widget buildDialog({
    required Category category,
    List<Category>? available,
    required Function(String?) onConfirm,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => CategoryDeleteDialog(
                category: category,
                availableCategories: available ?? availableCategories,
                onConfirm: onConfirm,
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  group('CategoryDeleteDialog', () {
    testWidgets('shows category name in title', (tester) async {
      await tester.pumpWidget(buildDialog(category: foodCategory, onConfirm: (_) {}));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Delete Category: Food'), findsOneWidget);
    });

    testWidgets('shows re-assign prompt', (tester) async {
      await tester.pumpWidget(buildDialog(category: foodCategory, onConfirm: (_) {}));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Re-assign existing transactions to:'), findsOneWidget);
    });

    testWidgets('shows dropdown with available categories', (tester) async {
      await tester.pumpWidget(buildDialog(category: foodCategory, onConfirm: (_) {}));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('first available category selected by default', (tester) async {
      await tester.pumpWidget(buildDialog(category: foodCategory, onConfirm: (_) {}));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets('can select different category from dropdown', (tester) async {
      await tester.pumpWidget(buildDialog(category: foodCategory, onConfirm: (_) {}));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entertainment'));
      await tester.pumpAndSettle();
      expect(find.text('Entertainment'), findsOneWidget);
    });

    testWidgets('Delete calls onConfirm and closes dialog', (tester) async {
      String? result;
      await tester.pumpWidget(buildDialog(
        category: foodCategory,
        onConfirm: (id) => result = id,
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(result, 'transport');
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Cancel closes dialog without calling onConfirm', (tester) async {
      var called = false;
      await tester.pumpWidget(buildDialog(
        category: foodCategory,
        onConfirm: (_) => called = true,
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(called, isFalse);
    });

    testWidgets('shows warning when no categories available', (tester) async {
      await tester.pumpWidget(buildDialog(
        category: foodCategory,
        available: [],
        onConfirm: (_) {},
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.textContaining('No other categories available'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsNothing);
    });

    testWidgets('onConfirm called with null when no categories', (tester) async {
      String? result;
      await tester.pumpWidget(buildDialog(
        category: foodCategory,
        available: [],
        onConfirm: (id) => result = id,
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });
  });
}
