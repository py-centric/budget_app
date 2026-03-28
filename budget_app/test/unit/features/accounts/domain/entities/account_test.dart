import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';

void main() {
  group('Account', () {
    test('should create Account with required fields', () {
      final account = Account(
        id: '1',
        name: 'Checking Account',
        type: AccountType.checking,
        balance: 1000.0,
        currency: 'USD',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(account.id, '1');
      expect(account.name, 'Checking Account');
      expect(account.type, AccountType.checking);
      expect(account.balance, 1000.0);
      expect(account.currency, 'USD');
    });

    test('should support all account types', () {
      expect(AccountType.checking.displayName, 'Checking');
      expect(AccountType.savings.displayName, 'Savings');
      expect(AccountType.investment.displayName, 'Investment');
      expect(AccountType.other.displayName, 'Other');
    });

    test('should parse account type from string', () {
      expect(AccountType.fromString('checking'), AccountType.checking);
      expect(AccountType.fromString('savings'), AccountType.savings);
      expect(AccountType.fromString('investment'), AccountType.investment);
      expect(AccountType.fromString('other'), AccountType.other);
      expect(AccountType.fromString('unknown'), AccountType.other);
    });

    test('should copy with new values', () {
      final account = Account(
        id: '1',
        name: 'Checking',
        type: AccountType.checking,
        balance: 1000.0,
        currency: 'USD',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final updated = account.copyWith(balance: 2000.0, name: 'Updated');

      expect(updated.balance, 2000.0);
      expect(updated.name, 'Updated');
      expect(updated.id, account.id);
    });
  });
}
