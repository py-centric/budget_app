import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';

void main() {
  group('Category', () {
    test('should support income type', () {
      const category = Category(id: '1', name: 'Salary', type: CategoryType.income);
      expect(category.type, equals(CategoryType.income));
    });

    test('should support expense type', () {
      const category = Category(id: '2', name: 'Food', type: CategoryType.expense);
      expect(category.type, equals(CategoryType.expense));
    });
  });
}
