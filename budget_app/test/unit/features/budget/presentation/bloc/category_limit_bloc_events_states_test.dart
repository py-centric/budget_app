import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/presentation/bloc/category_limit_event.dart';
import 'package:budget_app/features/budget/presentation/bloc/category_limit_state.dart';
import 'package:budget_app/features/budget/domain/entities/category_limit.dart';

void main() {
  group('CategoryLimitEvent', () {
    test('LoadCategoryLimits props', () {
      const event = LoadCategoryLimits(budgetId: 'b1', year: 2024, month: 6);
      expect(event.props, ['b1', 2024, 6]);
    });

    test('AddCategoryLimit props', () {
      const event = AddCategoryLimit(
        categoryId: 'food', amount: 100, period: LimitPeriod.weekly, budgetId: 'b1',
      );
      expect(event.props, ['food', 100, LimitPeriod.weekly, 'b1']);
    });

    test('UpdateCategoryLimit props', () {
      final limit = CategoryLimit(
        id: 'cl-1', categoryId: 'food', amount: 100,
        period: LimitPeriod.monthly, createdAt: DateTime.now(), updatedAt: DateTime.now(),
      );
      final event = UpdateCategoryLimit(limit);
      expect(event.props, [limit]);
    });

    test('DeleteCategoryLimit props', () {
      const event = DeleteCategoryLimit('cl-1');
      expect(event.props, ['cl-1']);
    });
  });

  group('CategoryLimitState', () {
    test('CategoryLimitInitial props', () {
      expect(CategoryLimitInitial().props, isEmpty);
    });

    test('CategoryLimitLoading props', () {
      expect(CategoryLimitLoading().props, isEmpty);
    });

    test('CategoryLimitError props', () {
      const state = CategoryLimitError('error');
      expect(state.props, ['error']);
    });

    test('CategoryLimitLoaded props', () {
      const state = CategoryLimitLoaded(limits: [], year: 2024, month: 6);
      expect(state.props, [[], 2024, 6]);
    });
  });

  group('CategoryLimitWithSpending', () {
    CategoryLimit makeLimit(double amount) => CategoryLimit(
      id: 'cl-1', categoryId: 'food', amount: amount,
      period: LimitPeriod.monthly, createdAt: DateTime.now(), updatedAt: DateTime.now(),
    );

    test('progressPercentage calculates correctly', () {
      final spending = CategoryLimitWithSpending(
        limit: makeLimit(100), spentAmount: 50, categoryName: 'Food',
      );
      expect(spending.progressPercentage, 50.0);
    });

    test('progressPercentage clamps to 100', () {
      final spending = CategoryLimitWithSpending(
        limit: makeLimit(100), spentAmount: 200, categoryName: 'Food',
      );
      expect(spending.progressPercentage, 100.0);
    });

    test('progressPercentage returns 0 when amount is 0', () {
      final spending = CategoryLimitWithSpending(
        limit: makeLimit(0), spentAmount: 50, categoryName: 'Food',
      );
      expect(spending.progressPercentage, 0);
    });

    test('remainingAmount clamps to 0 when over budget', () {
      final spending = CategoryLimitWithSpending(
        limit: makeLimit(100), spentAmount: 150, categoryName: 'Food',
      );
      expect(spending.remainingAmount, 0);
    });

    test('remainingAmount calculates correctly', () {
      final spending = CategoryLimitWithSpending(
        limit: makeLimit(100), spentAmount: 30, categoryName: 'Food',
      );
      expect(spending.remainingAmount, 70);
    });

    test('isOverBudget returns true when spent > limit', () {
      final spending = CategoryLimitWithSpending(
        limit: makeLimit(100), spentAmount: 150, categoryName: 'Food',
      );
      expect(spending.isOverBudget, isTrue);
    });

    test('isOverBudget returns false when spent <= limit', () {
      final spending = CategoryLimitWithSpending(
        limit: makeLimit(100), spentAmount: 100, categoryName: 'Food',
      );
      expect(spending.isOverBudget, isFalse);
    });

    test('categoryIcon is nullable', () {
      final spending = CategoryLimitWithSpending(
        limit: makeLimit(100), spentAmount: 50, categoryName: 'Food',
      );
      expect(spending.categoryIcon, isNull);
    });

    test('categoryIcon can be set', () {
      final spending = CategoryLimitWithSpending(
        limit: makeLimit(100), spentAmount: 50, categoryName: 'Food', categoryIcon: '🍔',
      );
      expect(spending.categoryIcon, '🍔');
    });
  });
}
