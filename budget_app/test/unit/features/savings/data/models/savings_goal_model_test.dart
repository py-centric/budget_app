import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/savings/data/models/savings_goal_model.dart';
import 'package:budget_app/features/savings/domain/entities/savings_goal.dart';

void main() {
  group('SavingsGoalModel', () {
    final testMap = {
      'id': '1',
      'name': 'Vacation',
      'target_amount': 5000.0,
      'current_amount': 1000.0,
      'deadline': '2026-12-31T00:00:00.000',
      'linked_category_id': 'cat1',
      'icon': 'beach',
      'color': 'blue',
      'is_completed': 0,
      'created_at': '2026-01-01T00:00:00.000',
      'updated_at': '2026-01-15T00:00:00.000',
    };

    final testEntity = SavingsGoal(
      id: '1',
      name: 'Vacation',
      targetAmount: 5000.0,
      currentAmount: 1000.0,
      deadline: DateTime(2026, 12, 31),
      linkedCategoryId: 'cat1',
      icon: 'beach',
      color: 'blue',
      isCompleted: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 15),
    );

    test('fromMap converts map to model correctly', () {
      final model = SavingsGoalModel.fromMap(testMap);

      expect(model.id, '1');
      expect(model.name, 'Vacation');
      expect(model.targetAmount, 5000.0);
      expect(model.currentAmount, 1000.0);
      expect(model.isCompleted, false);
    });

    test('toMap converts model to map correctly', () {
      final model = SavingsGoalModel.fromEntity(testEntity);
      final map = model.toMap();

      expect(map['id'], '1');
      expect(map['name'], 'Vacation');
      expect(map['target_amount'], 5000.0);
      expect(map['current_amount'], 1000.0);
      expect(map['is_completed'], 0);
    });

    test('fromEntity creates model from entity', () {
      final model = SavingsGoalModel.fromEntity(testEntity);

      expect(model.id, testEntity.id);
      expect(model.name, testEntity.name);
      expect(model.targetAmount, testEntity.targetAmount);
      expect(model.currentAmount, testEntity.currentAmount);
    });

    test('roundtrip fromMap toMap preserves data', () {
      final model = SavingsGoalModel.fromMap(testMap);
      final map = model.toMap();
      final model2 = SavingsGoalModel.fromMap(map);

      expect(model2.id, model.id);
      expect(model2.name, model.name);
      expect(model2.targetAmount, model.targetAmount);
      expect(model2.currentAmount, model.currentAmount);
      expect(model2.isCompleted, model.isCompleted);
    });
  });
}
