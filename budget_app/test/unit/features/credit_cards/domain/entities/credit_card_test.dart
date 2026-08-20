import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/credit_cards/domain/entities/credit_card.dart';

void main() {
  group('CreditCard', () {
    final now = DateTime(2024, 6, 15);
    final card = CreditCard(
      id: 'cc-1',
      name: 'Visa Platinum',
      lastFour: '1234',
      creditLimit: 10000,
      currentBalance: 2500,
      apr: 18.99,
      billingDay: 15,
      paymentDueDay: 25,
      minimumPaymentPercent: 2.0,
      lastUpdated: now,
    );

    test('props are correct', () {
      expect(card.props, [
        'cc-1', 'Visa Platinum', '1234', 10000, 2500,
        18.99, 15, 25,
      ]);
    });

    test('copyWith creates new instance', () {
      final updated = card.copyWith(currentBalance: 3000);
      expect(updated.currentBalance, 3000);
      expect(updated.name, 'Visa Platinum');
      expect(updated, isNot(equals(card)));
    });

    test('copyWith with no args returns equal instance', () {
      expect(card.copyWith(), equals(card));
    });

    test('utilizationPercent calculates correctly', () {
      expect(card.utilizationPercent, 25.0);
    });

    test('utilizationPercent with zero limit returns 0', () {
      final zeroLimit = card.copyWith(creditLimit: 0);
      expect(zeroLimit.utilizationPercent, 0);
    });

    test('minimumPayment calculates correctly', () {
      expect(card.minimumPayment, 50.0);
    });

    test('availableCredit calculates correctly', () {
      expect(card.availableCredit, 7500.0);
    });

    test('toMap serializes correctly', () {
      final map = card.toMap();
      expect(map['id'], 'cc-1');
      expect(map['name'], 'Visa Platinum');
      expect(map['last_four'], '1234');
      expect(map['credit_limit'], 10000);
      expect(map['current_balance'], 2500);
      expect(map['apr'], 18.99);
      expect(map['minimum_payment_percent'], 2.0);
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'id': 'cc-1', 'name': 'Visa Platinum', 'last_four': '1234',
        'credit_limit': 10000, 'current_balance': 2500,
        'apr': 18.99, 'billing_day': 15, 'payment_due_day': 25,
        'minimum_payment_percent': 2.0,
        'last_updated': now.toIso8601String(),
      };
      final result = CreditCard.fromMap(map);
      expect(result.id, 'cc-1');
      expect(result.name, 'Visa Platinum');
      expect(result.creditLimit, 10000);
      expect(result.apr, 18.99);
    });

    test('fromMap with null optional fields', () {
      final map = {
        'id': 'cc-1', 'name': 'Test Card',
        'last_four': null, 'credit_limit': 5000,
        'current_balance': null, 'apr': null,
        'billing_day': null, 'payment_due_day': null,
        'minimum_payment_percent': null, 'last_updated': null,
      };
      final result = CreditCard.fromMap(map);
      expect(result.lastFour, isNull);
      expect(result.billingDay, isNull);
    });

    test('default values', () {
      const minimal = CreditCard(id: 'cc-1', name: 'Test', creditLimit: 5000);
      expect(minimal.currentBalance, 0);
      expect(minimal.apr, 0);
      expect(minimal.minimumPaymentPercent, 2.0);
    });
  });
}
