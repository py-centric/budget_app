import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/emergency_fund/presentation/widgets/expense_item_tile.dart';
import 'package:budget_app/features/emergency_fund/domain/entities/emergency_expense.dart';

void main() {
  Widget buildTile({
    double amount = 100,
    bool isSuggestion = false,
    Function(double)? onAmountChanged,
    VoidCallback? onDelete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ExpenseItemTile(
          expense: EmergencyExpense(
            id: 'exp-1',
            name: 'Groceries',
            amount: amount,
            isSuggestion: isSuggestion,
            sortOrder: 0,
          ),
          onAmountChanged: onAmountChanged ?? (_) {},
          onDelete: onDelete,
        ),
      ),
    );
  }

  group('ExpenseItemTile', () {
    testWidgets('renders expense name', (tester) async {
      await tester.pumpWidget(buildTile());
      expect(find.text('Groceries'), findsNWidgets(2));
    });

    testWidgets('shows amount in text field', (tester) async {
      await tester.pumpWidget(buildTile(amount: 250.50));
      expect(find.text('250.50'), findsOneWidget);
    });

    testWidgets('empty text field when amount is 0', (tester) async {
      await tester.pumpWidget(buildTile(amount: 0));
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('shows "Suggested" label when isSuggestion is true', (tester) async {
      await tester.pumpWidget(buildTile(isSuggestion: true));
      expect(find.text('Suggested'), findsOneWidget);
    });

    testWidgets('hides "Suggested" label when isSuggestion is false', (tester) async {
      await tester.pumpWidget(buildTile(isSuggestion: false));
      expect(find.text('Suggested'), findsNothing);
    });

    testWidgets('shows delete button when onDelete provided and not suggestion', (tester) async {
      await tester.pumpWidget(buildTile(onDelete: () {}));
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('hides delete button when onDelete is null', (tester) async {
      await tester.pumpWidget(buildTile());
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('hides delete button when isSuggestion', (tester) async {
      await tester.pumpWidget(buildTile(isSuggestion: true, onDelete: () {}));
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('entering text calls onAmountChanged', (tester) async {
      double? changedAmount;
      await tester.pumpWidget(buildTile(
        amount: 0,
        onAmountChanged: (v) => changedAmount = v,
      ));
      await tester.enterText(find.byType(TextField), '150');
      expect(changedAmount, 150.0);
    });

    testWidgets('tapping delete calls onDelete', (tester) async {
      var deleted = false;
      await tester.pumpWidget(buildTile(onDelete: () => deleted = true));
      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deleted, isTrue);
    });

    testWidgets('updates controller when amount prop changes', (tester) async {
      final key = GlobalKey<State>();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ExpenseItemTile(
            key: key,
            expense: const EmergencyExpense(
              id: 'exp-1', name: 'Test', amount: 100,
              isSuggestion: false, sortOrder: 0,
            ),
            onAmountChanged: (_) {},
          ),
        ),
      ));
      expect(find.text('100.00'), findsOneWidget);
    });
  });
}
