import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/financial_tools/data/models/saved_calculation_model.dart';
import 'package:budget_app/features/financial_tools/domain/entities/saved_calculation.dart';

void main() {
  group('SavedCalculationModel', () {
    test('should create SavedCalculationModel with required fields', () {
      final model = SavedCalculationModel(
        id: '1',
        type: 'loan',
        name: 'My Loan',
        data: {'principal': 100000, 'rate': 5.0},
        createdAt: DateTime(2024, 1, 15),
      );

      expect(model.id, '1');
      expect(model.type, 'loan');
      expect(model.name, 'My Loan');
      expect(model.data['principal'], 100000);
    });

    test('should create SavedCalculationModel fromMap', () {
      final map = {
        'id': '1',
        'type': 'savings',
        'name': 'Emergency Fund',
        'data': '{"monthly":500,"goal":10000}',
        'created_at': '2024-01-15T00:00:00.000',
      };

      final model = SavedCalculationModel.fromMap(map);

      expect(model.id, '1');
      expect(model.type, 'savings');
      expect(model.name, 'Emergency Fund');
      expect(model.data['monthly'], 500);
    });

    test('toMap should return correct map', () {
      final model = SavedCalculationModel(
        id: '1',
        type: 'loan',
        name: 'Test Loan',
        data: {'rate': 4.5},
        createdAt: DateTime(2024, 1, 1),
      );

      final map = model.toMap();

      expect(map['id'], '1');
      expect(map['type'], 'loan');
      expect(map['data'], contains('rate'));
    });

    test('fromEntity should create model from entity', () {
      final entity = SavedCalculation(
        id: '1',
        type: 'investment',
        name: 'Investment Calc',
        data: {'initial': 5000},
        createdAt: DateTime(2024, 2, 1),
      );

      final model = SavedCalculationModel.fromEntity(entity);

      expect(model.id, '1');
      expect(model.type, 'investment');
      expect(model.data['initial'], 5000);
    });

    test('SavedCalculationModel should be a subtype of SavedCalculation', () {
      final model = SavedCalculationModel(
        id: '1',
        type: 'test',
        name: 'Test',
        data: {},
        createdAt: DateTime(2024, 1, 1),
      );

      expect(model, isA<SavedCalculation>());
    });
  });
}
