import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/presentation/widgets/expense_form.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';

void main() {
  final testCategories = [
    const Category(id: '1', name: 'Food', type: CategoryType.expense, icon: 'restaurant'),
    const Category(id: '2', name: 'Transport', type: CategoryType.expense, icon: 'directions_car'),
  ];

  group('ExpenseForm Widget Tests', () {
    testWidgets('should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseForm(
              categories: testCategories,
              onSubmit: (id, amount, categoryId, description, date, {endDate, interval, isRecurring = false, unit, isPotential = false}) {},
            ),
          ),
        ),
      );

      expect(find.text('Add Expense'), findsNWidgets(2));
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Description (optional)'), findsOneWidget);
    });

    testWidgets('should show validation error for empty amount', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseForm(
              categories: testCategories,
              onSubmit: (id, amount, categoryId, description, date, {endDate, interval, isRecurring = false, unit, isPotential = false}) {},
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Expense'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter an amount'), findsOneWidget);
    });

    testWidgets('should show validation error for zero amount', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseForm(
              categories: testCategories,
              onSubmit: (id, amount, categoryId, description, date, {endDate, interval, isRecurring = false, unit, isPotential = false}) {},
            ),
          ),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Amount'),
        '0',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Expense'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid positive amount'), findsOneWidget);
    });

    testWidgets('should show validation error for no category selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseForm(
              categories: testCategories,
              onSubmit: (id, amount, categoryId, description, date, {endDate, interval, isRecurring = false, unit, isPotential = false}) {},
            ),
          ),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Amount'),
        '50',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Expense'));
      await tester.pumpAndSettle();

      expect(find.text('Please select a category'), findsOneWidget);
    });
  });
}
