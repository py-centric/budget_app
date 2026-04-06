import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';

void main() {
  group('Category', () {
    test('should create Category with required fields', () {
      const category = Category(
        id: '1',
        name: 'Salary',
        type: CategoryType.income,
      );

      expect(category.id, '1');
      expect(category.name, 'Salary');
      expect(category.type, CategoryType.income);
      expect(category.icon, isNull);
    });

    test('should create Category with icon', () {
      const category = Category(
        id: '1',
        name: 'Food',
        type: CategoryType.expense,
        icon: 'restaurant',
      );

      expect(category.id, '1');
      expect(category.name, 'Food');
      expect(category.type, CategoryType.expense);
      expect(category.icon, 'restaurant');
    });

    test('CategoryType enum should have correct values', () {
      expect(CategoryType.values.length, 2);
      expect(CategoryType.income.index, 0);
      expect(CategoryType.expense.index, 1);
    });

    test('props should contain all fields', () {
      const category = Category(
        id: '1',
        name: 'Test',
        type: CategoryType.income,
        icon: 'test_icon',
      );

      expect(category.props, ['1', 'Test', CategoryType.income, 'test_icon']);
    });

    test('two categories with same values should be equal', () {
      const cat1 = Category(id: '1', name: 'Salary', type: CategoryType.income);

      const cat2 = Category(id: '1', name: 'Salary', type: CategoryType.income);

      expect(cat1, equals(cat2));
    });

    test('two categories with different values should not be equal', () {
      const cat1 = Category(id: '1', name: 'Salary', type: CategoryType.income);

      const cat2 = Category(id: '2', name: 'Food', type: CategoryType.expense);

      expect(cat1, isNot(equals(cat2)));
    });
  });
}
