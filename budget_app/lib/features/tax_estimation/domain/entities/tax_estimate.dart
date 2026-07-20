import 'package:equatable/equatable.dart';

class TaxEstimate extends Equatable {
  final double income;
  final double deductions;
  final double taxableIncome;
  final double effectiveRate;
  final double totalTax;
  final double takeHome;

  const TaxEstimate({
    required this.income,
    required this.deductions,
    required this.taxableIncome,
    required this.effectiveRate,
    required this.totalTax,
    required this.takeHome,
  });

  factory TaxEstimate.fromMap(Map<String, dynamic> map) {
    return TaxEstimate(
      income: (map['income'] as num).toDouble(),
      deductions: (map['deductions'] as num).toDouble(),
      taxableIncome: (map['taxable_income'] as num).toDouble(),
      effectiveRate: (map['effective_rate'] as num).toDouble(),
      totalTax: (map['total_tax'] as num).toDouble(),
      takeHome: (map['take_home'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'income': income,
      'deductions': deductions,
      'taxable_income': taxableIncome,
      'effective_rate': effectiveRate,
      'total_tax': totalTax,
      'take_home': takeHome,
    };
  }

  @override
  List<Object?> get props => [income, deductions, taxableIncome, effectiveRate, totalTax, takeHome];
}
