import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/calendar/presentation/bloc/calendar_state.dart';

void main() {
  group('CalendarTransaction', () {
    test('creates CalendarTransaction with correct values', () {
      final transaction = CalendarTransaction(
        id: '1',
        amount: 100.0,
        description: 'Test',
        date: DateTime(2026, 5, 1),
        isExpense: false,
        categoryName: 'Income',
        categoryIcon: 'money',
      );

      expect(transaction.id, '1');
      expect(transaction.amount, 100.0);
      expect(transaction.description, 'Test');
      expect(transaction.date, DateTime(2026, 5, 1));
      expect(transaction.isExpense, false);
      expect(transaction.categoryName, 'Income');
      expect(transaction.categoryIcon, 'money');
    });

    test('equality works correctly', () {
      final a = CalendarTransaction(
        id: '1',
        amount: 100.0,
        description: 'Test',
        date: DateTime(2026, 5, 1),
        isExpense: false,
      );
      final b = CalendarTransaction(
        id: '1',
        amount: 100.0,
        description: 'Test',
        date: DateTime(2026, 5, 1),
        isExpense: false,
      );

      expect(a, b);
    });

    test('inequality works correctly', () {
      final a = CalendarTransaction(
        id: '1',
        amount: 100.0,
        description: 'Test',
        date: DateTime(2026, 5, 1),
        isExpense: false,
      );
      final b = CalendarTransaction(
        id: '2',
        amount: 200.0,
        description: 'Different',
        date: DateTime(2026, 5, 2),
        isExpense: true,
      );

      expect(a, isNot(b));
    });
  });
}
