import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/financial_tools/domain/usecases/calculate_net_worth.dart';

void main() {
  test('should calculate net worth correctly', () {
    final calculateNetWorth = CalculateNetWorth();
    final assets = [1000.0, 5000.0, 200.0];
    final liabilities = [500.0, 1200.0];
    
    // Total Assets: 6200, Total Liabilities: 1700
    // Net Worth: 4500
    final result = calculateNetWorth(assets, liabilities);
    expect(result, 4500.0);
  });

  test('should handle empty lists', () {
    final calculateNetWorth = CalculateNetWorth();
    expect(calculateNetWorth([], []), 0.0);
  });
}
