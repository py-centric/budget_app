import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/emergency_fund/domain/entities/emergency_expense.dart';

void main() {
  group('EmergencyExpense', () {
    const testExpense = EmergencyExpense(
      id: '1',
      name: 'Rent',
      amount: 1500.0,
      isSuggestion: true,
      categoryType: 'housing',
      sortOrder: 0,
    );

    test('creates EmergencyExpense with correct values', () {
      expect(testExpense.id, '1');
      expect(testExpense.name, 'Rent');
      expect(testExpense.amount, 1500.0);
      expect(testExpense.isSuggestion, true);
      expect(testExpense.categoryType, 'housing');
      expect(testExpense.sortOrder, 0);
    });

    test('copyWith updates specified fields', () {
      final updated = testExpense.copyWith(
        amount: 1600.0,
        name: 'Rent Updated',
      );

      expect(updated.id, '1');
      expect(updated.name, 'Rent Updated');
      expect(updated.amount, 1600.0);
      expect(updated.isSuggestion, true);
      expect(updated.sortOrder, 0);
    });

    test('copyWith retains unspecified fields', () {
      final updated = testExpense.copyWith(amount: 1600.0);

      expect(updated.name, 'Rent');
      expect(updated.categoryType, 'housing');
      expect(updated.sortOrder, 0);
    });

    test('equality works correctly', () {
      const a = EmergencyExpense(
        id: '1',
        name: 'Rent',
        amount: 1500.0,
        isSuggestion: true,
        sortOrder: 0,
      );
      const b = EmergencyExpense(
        id: '1',
        name: 'Rent',
        amount: 1500.0,
        isSuggestion: true,
        sortOrder: 0,
      );

      expect(a, b);
    });

    test('inequality works correctly', () {
      const a = EmergencyExpense(
        id: '1',
        name: 'Rent',
        amount: 1500.0,
        isSuggestion: true,
        sortOrder: 0,
      );
      const b = EmergencyExpense(
        id: '2',
        name: 'Groceries',
        amount: 600.0,
        isSuggestion: false,
        sortOrder: 1,
      );

      expect(a, isNot(b));
    });
  });
}
