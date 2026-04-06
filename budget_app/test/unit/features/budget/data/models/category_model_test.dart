import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/data/models/category_model.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';

void main() {
  group('CategoryModel', () {
    test('should create CategoryModel with required fields', () {
      const model = CategoryModel(
        id: '1',
        name: 'Salary',
        type: CategoryType.income,
      );

      expect(model.id, '1');
      expect(model.name, 'Salary');
      expect(model.type, CategoryType.income);
      expect(model.icon, isNull);
    });

    test('should create CategoryModel with icon', () {
      const model = CategoryModel(
        id: '1',
        name: 'Food',
        type: CategoryType.expense,
        icon: 'restaurant',
      );

      expect(model.icon, 'restaurant');
    });

    test('should create CategoryModel fromMap for income', () {
      final map = {
        'id': '1',
        'name': 'Wages',
        'type': 'income',
        'icon': 'money',
      };

      final model = CategoryModel.fromMap(map);

      expect(model.id, '1');
      expect(model.name, 'Wages');
      expect(model.type, CategoryType.income);
      expect(model.icon, 'money');
    });

    test('should create CategoryModel fromMap for expense', () {
      final map = {'id': '2', 'name': 'Rent', 'type': 'expense'};

      final model = CategoryModel.fromMap(map);

      expect(model.type, CategoryType.expense);
    });

    test('toMap should return correct map for income', () {
      const model = CategoryModel(
        id: '1',
        name: 'Salary',
        type: CategoryType.income,
        icon: 'coins',
      );

      final map = model.toMap();

      expect(map['id'], '1');
      expect(map['name'], 'Salary');
      expect(map['type'], 'income');
      expect(map['icon'], 'coins');
    });

    test('toMap should return correct map for expense', () {
      const model = CategoryModel(
        id: '2',
        name: 'Food',
        type: CategoryType.expense,
      );

      final map = model.toMap();

      expect(map['type'], 'expense');
    });

    test('fromEntity should create CategoryModel from Category', () {
      const entity = Category(
        id: '1',
        name: 'Test Category',
        type: CategoryType.expense,
        icon: 'test_icon',
      );

      final model = CategoryModel.fromEntity(entity);

      expect(model.id, '1');
      expect(model.name, 'Test Category');
      expect(model.type, CategoryType.expense);
      expect(model.icon, 'test_icon');
    });

    test('CategoryModel should be a subtype of Category', () {
      const model = CategoryModel(
        id: '1',
        name: 'Test',
        type: CategoryType.income,
      );

      expect(model, isA<Category>());
    });
  });
}
