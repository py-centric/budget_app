import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/emergency_fund/data/models/emergency_expense_model.dart';
import 'package:budget_app/features/emergency_fund/domain/entities/emergency_expense.dart';

void main() {
  group('EmergencyExpenseModel', () {
    final testMap = {
      'id': '1',
      'name': 'Rent',
      'amount': 1500.0,
      'is_suggestion': 1,
      'category_type': 'housing',
      'sort_order': 0,
    };

    const testEntity = EmergencyExpense(
      id: '1',
      name: 'Rent',
      amount: 1500.0,
      isSuggestion: true,
      categoryType: 'housing',
      sortOrder: 0,
    );

    test('fromMap converts map to model correctly', () {
      final model = EmergencyExpenseModel.fromMap(testMap);

      expect(model.id, '1');
      expect(model.name, 'Rent');
      expect(model.amount, 1500.0);
      expect(model.isSuggestion, true);
      expect(model.categoryType, 'housing');
      expect(model.sortOrder, 0);
    });

    test('toMap converts model to map correctly', () {
      final model = EmergencyExpenseModel.fromEntity(testEntity);
      final map = model.toMap();

      expect(map['id'], '1');
      expect(map['name'], 'Rent');
      expect(map['amount'], 1500.0);
      expect(map['is_suggestion'], 1);
      expect(map['category_type'], 'housing');
      expect(map['sort_order'], 0);
    });

    test('fromEntity creates model from entity', () {
      final model = EmergencyExpenseModel.fromEntity(testEntity);

      expect(model.id, testEntity.id);
      expect(model.name, testEntity.name);
      expect(model.amount, testEntity.amount);
      expect(model.isSuggestion, testEntity.isSuggestion);
      expect(model.categoryType, testEntity.categoryType);
    });

    test('roundtrip fromMap toMap preserves data', () {
      final model = EmergencyExpenseModel.fromMap(testMap);
      final map = model.toMap();
      final model2 = EmergencyExpenseModel.fromMap(map);

      expect(model2.id, model.id);
      expect(model2.name, model.name);
      expect(model2.amount, model.amount);
      expect(model2.isSuggestion, model.isSuggestion);
      expect(model2.categoryType, model.categoryType);
    });
  });
}
