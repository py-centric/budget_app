import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/investments/domain/entities/investment.dart';

void main() {
  group('Investment', () {
    const investment = Investment(
      id: 'inv-1',
      name: 'S&P 500 ETF',
      ticker: 'SPY',
      shares: 10,
      avgCost: 400,
      currentPrice: 450,
    );

    test('props are correct', () {
      expect(investment.props, ['inv-1', 'S&P 500 ETF', 'SPY', 10, 400, 450]);
    });

    test('copyWith creates new instance', () {
      final updated = investment.copyWith(currentPrice: 500);
      expect(updated.currentPrice, 500);
      expect(updated.name, 'S&P 500 ETF');
      expect(updated, isNot(equals(investment)));
    });

    test('copyWith with no args returns equal instance', () {
      expect(investment.copyWith(), equals(investment));
    });

    test('totalValue calculates correctly', () {
      expect(investment.totalValue, 4500.0);
    });

    test('totalCost calculates correctly', () {
      expect(investment.totalCost, 4000.0);
    });

    test('gainLoss calculates correctly', () {
      expect(investment.gainLoss, 500.0);
    });

    test('roi calculates correctly', () {
      expect(investment.roi, closeTo(12.5, 0.01));
    });

    test('roi with zero cost returns 0', () {
      const zeroCost = Investment(
        id: 'inv-1', name: 'Test', ticker: 'T',
        shares: 10, avgCost: 0, currentPrice: 100,
      );
      expect(zeroCost.roi, 0);
    });

    test('toMap serializes correctly', () {
      final map = investment.toMap();
      expect(map['id'], 'inv-1');
      expect(map['name'], 'S&P 500 ETF');
      expect(map['ticker'], 'SPY');
      expect(map['shares'], 10);
      expect(map['avg_cost'], 400);
      expect(map['current_price'], 450);
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'id': 'inv-1', 'name': 'S&P 500 ETF', 'ticker': 'SPY',
        'shares': 10, 'avg_cost': 400, 'current_price': 450,
      };
      final result = Investment.fromMap(map);
      expect(result.id, 'inv-1');
      expect(result.name, 'S&P 500 ETF');
      expect(result.shares, 10);
    });

    test('equality works', () {
      const investment2 = Investment(
        id: 'inv-1', name: 'S&P 500 ETF', ticker: 'SPY',
        shares: 10, avgCost: 400, currentPrice: 450,
      );
      expect(investment, equals(investment2));
    });

    test('loss scenario', () {
      const losing = Investment(
        id: 'inv-2', name: 'Losing Stock', ticker: 'LOSS',
        shares: 10, avgCost: 500, currentPrice: 400,
      );
      expect(losing.gainLoss, -1000.0);
      expect(losing.roi, closeTo(-20.0, 0.01));
    });
  });
}
