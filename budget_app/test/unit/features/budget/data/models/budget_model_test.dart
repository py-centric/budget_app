import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/data/models/budget_model.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';

void main() {
  group('BudgetModel', () {
    test('should create BudgetModel with required fields', () {
      const model = BudgetModel(
        id: '1',
        name: 'January 2024',
        periodMonth: 1,
        periodYear: 2024,
      );

      expect(model.id, '1');
      expect(model.name, 'January 2024');
      expect(model.periodMonth, 1);
      expect(model.periodYear, 2024);
      expect(model.isActive, true);
    });

    test('should create BudgetModel fromMap', () {
      final map = {
        'id': '1',
        'name': 'Test Budget',
        'period_month': 6,
        'period_year': 2024,
        'is_active': 1,
        'currency_code': 'USD',
        'target_currency_code': 'EUR',
        'exchange_rate': 0.85,
        'converted_amount': 8500.0,
      };

      final model = BudgetModel.fromMap(map);

      expect(model.id, '1');
      expect(model.name, 'Test Budget');
      expect(model.periodMonth, 6);
      expect(model.periodYear, 2024);
      expect(model.isActive, true);
      expect(model.currencyCode, 'USD');
      expect(model.targetCurrencyCode, 'EUR');
      expect(model.exchangeRate, 0.85);
      expect(model.convertedAmount, 8500.0);
    });

    test('should create BudgetModel fromMap with is_active 0', () {
      final map = {
        'id': '1',
        'name': 'Test',
        'period_month': 1,
        'period_year': 2024,
        'is_active': 0,
      };

      final model = BudgetModel.fromMap(map);

      expect(model.isActive, false);
    });

    test('toMap should return correct map', () {
      const model = BudgetModel(
        id: '1',
        name: 'Test Budget',
        periodMonth: 3,
        periodYear: 2024,
        isActive: false,
        currencyCode: 'GBP',
      );

      final map = model.toMap();

      expect(map['id'], '1');
      expect(map['name'], 'Test Budget');
      expect(map['period_month'], 3);
      expect(map['period_year'], 2024);
      expect(map['is_active'], 0);
      expect(map['currency_code'], 'GBP');
    });

    test('fromEntity should create BudgetModel from Budget', () {
      const entity = Budget(
        id: '1',
        name: 'Entity Budget',
        periodMonth: 5,
        periodYear: 2024,
        isActive: true,
        currencyCode: 'JPY',
      );

      final model = BudgetModel.fromEntity(entity);

      expect(model.id, '1');
      expect(model.name, 'Entity Budget');
      expect(model.periodMonth, 5);
      expect(model.periodYear, 2024);
      expect(model.isActive, true);
      expect(model.currencyCode, 'JPY');
    });

    test('BudgetModel should be a subtype of Budget', () {
      const model = BudgetModel(
        id: '1',
        name: 'Test',
        periodMonth: 1,
        periodYear: 2024,
      );

      expect(model, isA<Budget>());
    });
  });
}
