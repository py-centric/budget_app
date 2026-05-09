import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/reminders/data/models/bill_reminder_model.dart';
import 'package:budget_app/features/reminders/domain/entities/bill_reminder.dart';

void main() {
  group('BillReminderModel', () {
    final testMap = {
      'id': '1',
      'recurring_transaction_id': 'rt1',
      'due_date': '2026-06-15T00:00:00.000',
      'days_before_due': 3,
      'is_notified': 0,
      'notified_at': null,
      'created_at': '2026-05-01T00:00:00.000',
    };

    final testEntity = BillReminder(
      id: '1',
      recurringTransactionId: 'rt1',
      dueDate: DateTime(2026, 6, 15),
      daysBeforeDue: 3,
      isNotified: false,
      createdAt: DateTime(2026, 5, 1),
    );

    test('fromMap converts map to model correctly', () {
      final model = BillReminderModel.fromMap(testMap);

      expect(model.id, '1');
      expect(model.recurringTransactionId, 'rt1');
      expect(model.daysBeforeDue, 3);
      expect(model.isNotified, false);
    });

    test('toMap converts model to map correctly', () {
      final model = BillReminderModel.fromEntity(testEntity);
      final map = model.toMap();

      expect(map['id'], '1');
      expect(map['recurring_transaction_id'], 'rt1');
      expect(map['days_before_due'], 3);
      expect(map['is_notified'], 0);
    });

    test('fromEntity creates model from entity', () {
      final model = BillReminderModel.fromEntity(testEntity);

      expect(model.id, testEntity.id);
      expect(model.recurringTransactionId, testEntity.recurringTransactionId);
      expect(model.daysBeforeDue, testEntity.daysBeforeDue);
      expect(model.isNotified, testEntity.isNotified);
    });

    test('toEntity converts model to entity', () {
      final model = BillReminderModel.fromEntity(testEntity);
      final entity = model.toEntity();

      expect(entity.id, testEntity.id);
      expect(entity.recurringTransactionId, testEntity.recurringTransactionId);
      expect(entity.dueDate, testEntity.dueDate);
    });

    test('roundtrip fromMap toMap preserves data', () {
      final model = BillReminderModel.fromMap(testMap);
      final map = model.toMap();
      final model2 = BillReminderModel.fromMap(map);

      expect(model2.id, model.id);
      expect(model2.recurringTransactionId, model.recurringTransactionId);
      expect(model2.daysBeforeDue, model.daysBeforeDue);
      expect(model2.isNotified, model.isNotified);
    });
  });
}
