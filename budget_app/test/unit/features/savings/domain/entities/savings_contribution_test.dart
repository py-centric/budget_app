import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/savings/domain/entities/savings_contribution.dart';

void main() {
  group('SavingsContribution', () {
    final testContribution = SavingsContribution(
      id: 'c1',
      goalId: 'g1',
      amount: 500.0,
      date: DateTime(2026, 5, 1),
      note: 'Monthly contribution',
      createdAt: DateTime(2026, 5, 1),
    );

    test('creates SavingsContribution with correct values', () {
      expect(testContribution.id, 'c1');
      expect(testContribution.goalId, 'g1');
      expect(testContribution.amount, 500.0);
      expect(testContribution.date, DateTime(2026, 5, 1));
      expect(testContribution.note, 'Monthly contribution');
    });

    test('copyWith updates specified fields', () {
      final updated = testContribution.copyWith(
        amount: 600.0,
        note: 'Updated contribution',
      );

      expect(updated.amount, 600.0);
      expect(updated.note, 'Updated contribution');
      expect(updated.goalId, 'g1');
    });

    test('equality works correctly', () {
      final a = SavingsContribution(
        id: 'c1',
        goalId: 'g1',
        amount: 500.0,
        date: DateTime(2026, 5, 1),
        createdAt: DateTime(2026, 5, 1),
      );
      final b = SavingsContribution(
        id: 'c1',
        goalId: 'g1',
        amount: 500.0,
        date: DateTime(2026, 5, 1),
        createdAt: DateTime(2026, 5, 1),
      );

      expect(a, b);
    });

    test('inequality works correctly', () {
      expect(testContribution, isNot(
        testContribution.copyWith(amount: 600.0),
      ));
    });
  });
}
