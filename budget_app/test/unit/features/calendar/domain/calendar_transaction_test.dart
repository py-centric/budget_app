import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/calendar/domain/entities/calendar_event.dart';

void main() {
  group('CalendarEvent', () {
    test('creates CalendarEvent with correct values', () {
      final transaction = CalendarEvent(
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
      final a = CalendarEvent(
        id: '1',
        amount: 100.0,
        description: 'Test',
        date: DateTime(2026, 5, 1),
        isExpense: false,
      );
      final b = CalendarEvent(
        id: '1',
        amount: 100.0,
        description: 'Test',
        date: DateTime(2026, 5, 1),
        isExpense: false,
      );

      expect(a, b);
    });

    test('inequality works correctly', () {
      final a = CalendarEvent(
        id: '1',
        amount: 100.0,
        description: 'Test',
        date: DateTime(2026, 5, 1),
        isExpense: false,
      );
      final b = CalendarEvent(
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
