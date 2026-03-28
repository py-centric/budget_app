import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/accounts/data/models/account_model.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';

void main() {
  group('AccountModel', () {
    test('should create from map', () {
      final map = {
        'id': '1',
        'name': 'Savings',
        'type': 'savings',
        'balance': 5000.0,
        'currency': 'EUR',
        'created_at': 1704067200000,
        'updated_at': 1704067200000,
      };

      final model = AccountModel.fromMap(map);

      expect(model.id, '1');
      expect(model.name, 'Savings');
      expect(model.type, AccountType.savings);
      expect(model.balance, 5000.0);
      expect(model.currency, 'EUR');
    });

    test('should convert to map', () {
      final model = AccountModel(
        id: '1',
        name: 'Investment',
        type: AccountType.investment,
        balance: 10000.0,
        currency: 'USD',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final map = model.toMap();

      expect(map['id'], '1');
      expect(map['name'], 'Investment');
      expect(map['type'], 'investment');
      expect(map['balance'], 10000.0);
      expect(map['currency'], 'USD');
    });

    test('should create from entity', () {
      final entity = Account(
        id: '1',
        name: 'Checking',
        type: AccountType.checking,
        balance: 1000.0,
        currency: 'USD',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final model = AccountModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.name, entity.name);
      expect(model.balance, entity.balance);
    });
  });
}
