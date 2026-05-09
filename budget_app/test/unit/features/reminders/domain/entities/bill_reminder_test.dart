import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/reminders/domain/entities/bill_reminder.dart';

void main() {
  group('BillReminder', () {
    test('creates BillReminder with correct values', () {
      final reminder = BillReminder(
        id: '1',
        recurringTransactionId: 'rt1',
        dueDate: DateTime(2026, 6, 15),
        daysBeforeDue: 3,
        isNotified: false,
        createdAt: DateTime(2026, 5, 1),
      );

      expect(reminder.id, '1');
      expect(reminder.recurringTransactionId, 'rt1');
      expect(reminder.dueDate, DateTime(2026, 6, 15));
      expect(reminder.daysBeforeDue, 3);
      expect(reminder.isNotified, false);
    });

    test('reminderDate is dueDate minus daysBeforeDue', () {
      final reminder = BillReminder(
        id: '1',
        recurringTransactionId: 'rt1',
        dueDate: DateTime(2026, 6, 15),
        daysBeforeDue: 3,
        createdAt: DateTime(2026, 5, 1),
      );

      expect(reminder.reminderDate, DateTime(2026, 6, 12));
    });

    test('shouldNotify returns false when already notified', () {
      final reminder = BillReminder(
        id: '1',
        recurringTransactionId: 'rt1',
        dueDate: DateTime(2026, 6, 15),
        daysBeforeDue: 3,
        isNotified: true,
        createdAt: DateTime(2026, 5, 1),
      );

      expect(reminder.shouldNotify, false);
    });

    test('copyWith updates specified fields', () {
      final reminder = BillReminder(
        id: '1',
        recurringTransactionId: 'rt1',
        dueDate: DateTime(2026, 6, 15),
        daysBeforeDue: 3,
        createdAt: DateTime(2026, 5, 1),
      );

      final updated = reminder.copyWith(daysBeforeDue: 5);
      expect(updated.daysBeforeDue, 5);
      expect(updated.id, '1');
    });

    test('equality works correctly', () {
      final a = BillReminder(
        id: '1',
        recurringTransactionId: 'rt1',
        dueDate: DateTime(2026, 6, 15),
        daysBeforeDue: 3,
        createdAt: DateTime(2026, 5, 1),
      );
      final b = BillReminder(
        id: '1',
        recurringTransactionId: 'rt1',
        dueDate: DateTime(2026, 6, 15),
        daysBeforeDue: 3,
        createdAt: DateTime(2026, 5, 1),
      );

      expect(a, b);
    });
  });
}
