import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final String id;
  final String name;
  final int periodMonth;
  final int periodYear;
  final bool isActive;
  final String? currencyCode;
  final String? targetCurrencyCode;
  final double? exchangeRate;
  final double? convertedAmount;

  const Budget({
    required this.id,
    required this.name,
    required this.periodMonth,
    required this.periodYear,
    this.isActive = true,
    this.currencyCode,
    this.targetCurrencyCode,
    this.exchangeRate,
    this.convertedAmount,
  });

  Budget copyWith({
    String? id,
    String? name,
    int? periodMonth,
    int? periodYear,
    bool? isActive,
    String? currencyCode,
    String? targetCurrencyCode,
    double? exchangeRate,
    double? convertedAmount,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      periodMonth: periodMonth ?? this.periodMonth,
      periodYear: periodYear ?? this.periodYear,
      isActive: isActive ?? this.isActive,
      currencyCode: currencyCode ?? this.currencyCode,
      targetCurrencyCode: targetCurrencyCode ?? this.targetCurrencyCode,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      convertedAmount: convertedAmount ?? this.convertedAmount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    periodMonth,
    periodYear,
    isActive,
    currencyCode,
    targetCurrencyCode,
    exchangeRate,
    convertedAmount,
  ];
}
