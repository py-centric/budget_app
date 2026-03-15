import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/presentation/widgets/slidable_transaction_item.dart';

void main() {
  group('SlidableTransactionItem', () {
    testWidgets('calls onDelete when delete action is tapped', (WidgetTester tester) async {
      bool deleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlidableTransactionItem(
              onEdit: () {},
              onDelete: () {
                deleteCalled = true;
              },
              child: const ListTile(title: Text('Transaction')),
            ),
          ),
        ),
      );

      // Initially action is not visible
      expect(find.text('Delete'), findsNothing);

      // Slide to reveal actions
      await tester.drag(find.text('Transaction'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Now "Delete" should be visible
      final deleteAction = find.text('Delete');
      expect(deleteAction, findsOneWidget);

      // Tap delete
      await tester.tap(deleteAction);
      await tester.pumpAndSettle();

      expect(deleteCalled, isTrue);
    });

    testWidgets('calls onEdit when edit action is tapped', (WidgetTester tester) async {
      bool editCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlidableTransactionItem(
              onEdit: () {
                editCalled = true;
              },
              onDelete: () {},
              child: const ListTile(title: Text('Transaction')),
            ),
          ),
        ),
      );

      // Slide to reveal actions
      await tester.drag(find.text('Transaction'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      final editAction = find.text('Edit');
      expect(editAction, findsOneWidget);

      await tester.tap(editAction);
      await tester.pumpAndSettle();

      expect(editCalled, isTrue);
    });
  });
}
