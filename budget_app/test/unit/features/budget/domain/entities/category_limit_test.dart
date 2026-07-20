import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/domain/entities/category_limit.dart';

void main() {
  group('CategoryLimit', () {
    final now = DateTime(2024, 6, 15);
    final limit = CategoryLimit(
      id: 'cl-1',
      categoryId: 'food',
      amount: 500,
      period: LimitPeriod.monthly,
      createdAt: now,
      updatedAt: now,
    );

    test('props are correct', () {
      expect(limit.props, ['cl-1', 'food', 500, LimitPeriod.monthly, now, now]);
    });

    test('copyWith creates new instance with changed fields', () {
      final updated = limit.copyWith(amount: 600);
      expect(updated.amount, 600);
      expect(updated.id, 'cl-1');
      expect(updated, isNot(equals(limit)));
    });

    test('copyWith with no args returns equal instance', () {
      final copy = limit.copyWith();
      expect(copy, equals(limit));
    });

    test('LimitPeriod has correct values', () {
      expect(LimitPeriod.values, [LimitPeriod.weekly, LimitPeriod.monthly]);
    });
  });
}
