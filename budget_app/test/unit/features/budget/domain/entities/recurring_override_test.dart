import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/domain/entities/recurring_override.dart';

void main() {
  group('RecurringOverride', () {
    test('should create with required fields', () {
      final override = RecurringOverride(
        id: '1',
        recurringTransactionId: 'rec1',
        targetDate: DateTime(2024, 1, 15),
      );

      expect(override.id, '1');
      expect(override.recurringTransactionId, 'rec1');
      expect(override.targetDate, DateTime(2024, 1, 15));
      expect(override.newAmount, isNull);
      expect(override.isDeleted, false);
    });

    test('should create with optional fields', () {
      final override = RecurringOverride(
        id: '1',
        recurringTransactionId: 'rec1',
        targetDate: DateTime(2024, 1, 15),
        newAmount: 50.0,
        isDeleted: true,
      );

      expect(override.newAmount, 50.0);
      expect(override.isDeleted, true);
    });
  });
}
