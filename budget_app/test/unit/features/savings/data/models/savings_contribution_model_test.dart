import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/savings/data/models/savings_contribution_model.dart';
import 'package:budget_app/features/savings/domain/entities/savings_contribution.dart';

void main() {
  group('SavingsContributionModel', () {
    final testMap = {
      'id': 'c1',
      'goal_id': 'g1',
      'amount': 500.0,
      'date': '2026-05-01T00:00:00.000',
      'note': 'Monthly contribution',
      'created_at': '2026-05-01T00:00:00.000',
    };

    final testEntity = SavingsContribution(
      id: 'c1',
      goalId: 'g1',
      amount: 500.0,
      date: DateTime(2026, 5, 1),
      note: 'Monthly contribution',
      createdAt: DateTime(2026, 5, 1),
    );

    test('fromMap converts map to model correctly', () {
      final model = SavingsContributionModel.fromMap(testMap);

      expect(model.id, 'c1');
      expect(model.goalId, 'g1');
      expect(model.amount, 500.0);
      expect(model.note, 'Monthly contribution');
    });

    test('toMap converts model to map correctly', () {
      final model = SavingsContributionModel.fromEntity(testEntity);
      final map = model.toMap();

      expect(map['id'], 'c1');
      expect(map['goal_id'], 'g1');
      expect(map['amount'], 500.0);
      expect(map['note'], 'Monthly contribution');
    });

    test('fromEntity creates model from entity', () {
      final model = SavingsContributionModel.fromEntity(testEntity);

      expect(model.id, testEntity.id);
      expect(model.goalId, testEntity.goalId);
      expect(model.amount, testEntity.amount);
      expect(model.date, testEntity.date);
    });

    test('roundtrip fromMap toMap preserves data', () {
      final model = SavingsContributionModel.fromMap(testMap);
      final map = model.toMap();
      final model2 = SavingsContributionModel.fromMap(map);

      expect(model2.id, model.id);
      expect(model2.goalId, model.goalId);
      expect(model2.amount, model.amount);
      expect(model2.note, model.note);
    });
  });
}
