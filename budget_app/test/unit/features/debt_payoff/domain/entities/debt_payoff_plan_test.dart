import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/debt_payoff/domain/entities/debt_payoff_plan.dart';

void main() {
  group('DebtPayoffPlan', () {
    const plan = DebtPayoffPlan(
      strategy: PayoffStrategy.snowball,
      debts: [
        DebtPayoffItem(
          name: 'Visa', balance: 5000, apr: 18.99,
          minimumPayment: 100, payoffOrder: 1,
          monthsToPayoff: 12, interestPaid: 500,
        ),
        DebtPayoffItem(
          name: 'Mastercard', balance: 3000, apr: 15.99,
          minimumPayment: 75, payoffOrder: 2,
          monthsToPayoff: 8, interestPaid: 200,
        ),
      ],
      monthlyPayment: 500,
      totalMonths: 24,
      totalInterest: 2500,
      totalPaid: 20500,
    );

    test('props are correct', () {
      expect(plan.props, [
        PayoffStrategy.snowball, plan.debts, 500, 24, 2500, 20500,
      ]);
    });

    test('equality works', () {
      const plan2 = DebtPayoffPlan(
        strategy: PayoffStrategy.snowball,
        debts: [
          DebtPayoffItem(
            name: 'Visa', balance: 5000, apr: 18.99,
            minimumPayment: 100, payoffOrder: 1,
            monthsToPayoff: 12, interestPaid: 500,
          ),
          DebtPayoffItem(
            name: 'Mastercard', balance: 3000, apr: 15.99,
            minimumPayment: 75, payoffOrder: 2,
            monthsToPayoff: 8, interestPaid: 200,
          ),
        ],
        monthlyPayment: 500, totalMonths: 24,
        totalInterest: 2500, totalPaid: 20500,
      );
      expect(plan, equals(plan2));
    });

    test('PayoffStrategy has correct values', () {
      expect(PayoffStrategy.values.length, 3);
      expect(PayoffStrategy.values, contains(PayoffStrategy.snowball));
      expect(PayoffStrategy.values, contains(PayoffStrategy.avalanche));
      expect(PayoffStrategy.values, contains(PayoffStrategy.custom));
    });
  });

  group('DebtPayoffItem', () {
    const item = DebtPayoffItem(
      name: 'Visa',
      balance: 5000,
      apr: 18.99,
      minimumPayment: 100,
      payoffOrder: 1,
      monthsToPayoff: 12,
      interestPaid: 500,
    );

    test('props are correct', () {
      expect(item.props, ['Visa', 5000, 18.99, 100, 1, 12, 500]);
    });

    test('equality works', () {
      const item2 = DebtPayoffItem(
        name: 'Visa', balance: 5000, apr: 18.99,
        minimumPayment: 100, payoffOrder: 1,
        monthsToPayoff: 12, interestPaid: 500,
      );
      expect(item, equals(item2));
    });

    test('inequality with different balance', () {
      const item2 = DebtPayoffItem(
        name: 'Visa', balance: 6000, apr: 18.99,
        minimumPayment: 100, payoffOrder: 1,
        monthsToPayoff: 12, interestPaid: 500,
      );
      expect(item, isNot(equals(item2)));
    });
  });
}
