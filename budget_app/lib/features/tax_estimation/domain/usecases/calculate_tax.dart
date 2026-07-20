import '../entities/tax_estimate.dart';

class CalculateTax {
  static const List<Map<String, dynamic>> _brackets = [
    {'min': 0, 'max': 11600, 'rate': 0.10},
    {'min': 11600, 'max': 47150, 'rate': 0.12},
    {'min': 47150, 'max': 100525, 'rate': 0.22},
    {'min': 100525, 'max': 191950, 'rate': 0.24},
    {'min': 191950, 'max': 243725, 'rate': 0.32},
    {'min': 243725, 'max': 609350, 'rate': 0.35},
    {'min': 609350, 'max': double.infinity, 'rate': 0.37},
  ];

  TaxEstimate call({required double income, required double deductions}) {
    final taxableIncome = (income - deductions).clamp(0.0, double.infinity);
    double totalTax = 0;

    for (final bracket in _brackets) {
      final min = bracket['min'] as double;
      final max = bracket['max'] as double;
      final rate = bracket['rate'] as double;

      if (taxableIncome > min) {
        final taxableInBracket = (taxableIncome - min).clamp(0.0, max - min);
        totalTax += taxableInBracket * rate;
      }
    }

    final effectiveRate = income > 0 ? (totalTax / income * 100) : 0.0;
    final takeHome = income - totalTax;

    return TaxEstimate(
      income: income,
      deductions: deductions,
      taxableIncome: taxableIncome,
      effectiveRate: effectiveRate,
      totalTax: totalTax,
      takeHome: takeHome,
    );
  }
}
