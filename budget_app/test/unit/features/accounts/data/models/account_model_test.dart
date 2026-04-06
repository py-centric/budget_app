import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/accounts/data/models/account_model.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';

void main() {
  group('AccountModel', () {
    test('should create AccountModel with required fields', () {
      final model = AccountModel(
        id: '1',
        name: 'Main Account',
        type: AccountType.checking,
        balance: 1000.0,
        currency: 'USD',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(model.id, '1');
      expect(model.name, 'Main Account');
      expect(model.type, AccountType.checking);
      expect(model.balance, 1000.0);
      expect(model.currency, 'USD');
    });

    test('should create AccountModel fromMap', () {
      final map = {
        'id': '1',
        'name': 'Savings Account',
        'type': 'savings',
        'balance': 5000.0,
        'currency': 'EUR',
        'created_at': DateTime(2024, 1, 1).millisecondsSinceEpoch,
        'updated_at': DateTime(2024, 1, 15).millisecondsSinceEpoch,
      };

      final model = AccountModel.fromMap(map);

      expect(model.id, '1');
      expect(model.name, 'Savings Account');
      expect(model.type, AccountType.savings);
      expect(model.balance, 5000.0);
      expect(model.currency, 'EUR');
    });

    test('should create AccountModel fromMap with different types', () {
      expect(
        AccountModel.fromMap({
          'id': '1',
          'name': 'Test',
          'type': 'checking',
          'balance': 100.0,
          'currency': 'USD',
          'created_at': 0,
          'updated_at': 0,
        }).type,
        AccountType.checking,
      );

      expect(
        AccountModel.fromMap({
          'id': '1',
          'name': 'Test',
          'type': 'savings',
          'balance': 100.0,
          'currency': 'USD',
          'created_at': 0,
          'updated_at': 0,
        }).type,
        AccountType.savings,
      );

      expect(
        AccountModel.fromMap({
          'id': '1',
          'name': 'Test',
          'type': 'investment',
          'balance': 100.0,
          'currency': 'USD',
          'created_at': 0,
          'updated_at': 0,
        }).type,
        AccountType.investment,
      );

      expect(
        AccountModel.fromMap({
          'id': '1',
          'name': 'Test',
          'type': 'other',
          'balance': 100.0,
          'currency': 'USD',
          'created_at': 0,
          'updated_at': 0,
        }).type,
        AccountType.other,
      );
    });

    test('toMap should return correct map', () {
      final model = AccountModel(
        id: '1',
        name: 'Test Account',
        type: AccountType.checking,
        balance: 2500.0,
        currency: 'GBP',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 2, 1),
      );

      final map = model.toMap();

      expect(map['id'], '1');
      expect(map['name'], 'Test Account');
      expect(map['type'], 'checking');
      expect(map['balance'], 2500.0);
      expect(map['currency'], 'GBP');
    });

    test('fromEntity should create model from entity', () {
      final entity = Account(
        id: '1',
        name: 'Entity Account',
        type: AccountType.savings,
        balance: 7500.0,
        currency: 'JPY',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final model = AccountModel.fromEntity(entity);

      expect(model.id, '1');
      expect(model.name, 'Entity Account');
      expect(model.type, AccountType.savings);
      expect(model.balance, 7500.0);
      expect(model.currency, 'JPY');
    });

    test('AccountModel should be a subtype of Account', () {
      final model = AccountModel(
        id: '1',
        name: 'Test',
        type: AccountType.checking,
        balance: 100.0,
        currency: 'USD',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(model, isA<Account>());
    });
  });
}
