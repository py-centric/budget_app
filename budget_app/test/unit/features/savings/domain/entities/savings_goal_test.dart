import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/savings/domain/entities/savings_goal.dart';

void main() {
  group('SavingsGoal', () {
    final testGoal = SavingsGoal(
      id: '1',
      name: 'Vacation',
      targetAmount: 5000.0,
      currentAmount: 1000.0,
      deadline: DateTime(2026, 12, 31),
      icon: 'beach',
      color: 'blue',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    test('creates SavingsGoal with correct values', () {
      expect(testGoal.id, '1');
      expect(testGoal.name, 'Vacation');
      expect(testGoal.targetAmount, 5000.0);
      expect(testGoal.currentAmount, 1000.0);
      expect(testGoal.isCompleted, false);
    });

    test('progressPercentage returns correct value', () {
      expect(testGoal.progressPercentage, 20.0);
    });

    test('progressPercentage clamps between 0 and 100', () {
      final overGoal = SavingsGoal(
        id: '2',
        name: 'Over',
        targetAmount: 100.0,
        currentAmount: 200.0,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      expect(overGoal.progressPercentage, 100.0);

      final zeroGoal = SavingsGoal(
        id: '3',
        name: 'Zero',
        targetAmount: 0,
        currentAmount: 0,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      expect(zeroGoal.progressPercentage, 0.0);
    });

    test('remainingAmount returns correct value', () {
      expect(testGoal.remainingAmount, 4000.0);
    });

    test('remainingAmount clamps to 0', () {
      final overGoal = SavingsGoal(
        id: '2',
        name: 'Over',
        targetAmount: 100.0,
        currentAmount: 200.0,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      expect(overGoal.remainingAmount, 0.0);
    });

    test('isOverdue returns false when no deadline', () {
      final noDeadline = SavingsGoal(
        id: '3',
        name: 'No Deadline',
        targetAmount: 100.0,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      expect(noDeadline.isOverdue, false);
    });

    test('copyWith updates specified fields', () {
      final updated = testGoal.copyWith(
        name: 'New Vacation',
        currentAmount: 2000.0,
      );

      expect(updated.name, 'New Vacation');
      expect(updated.currentAmount, 2000.0);
      expect(updated.targetAmount, 5000.0);
    });

    test('equality works correctly', () {
      final a = SavingsGoal(
        id: '1',
        name: 'Vacation',
        targetAmount: 5000.0,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      final b = SavingsGoal(
        id: '1',
        name: 'Vacation',
        targetAmount: 5000.0,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(a, b);
    });
  });
}
