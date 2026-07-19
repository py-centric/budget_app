import 'package:equatable/equatable.dart';

enum BudgetType { regular, disposable, disposed, persisted }

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
  final BudgetType type;
  final double? targetIncome;
  final String? sourceDescription;
  final String? linkedIncomeId;

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
    this.type = BudgetType.regular,
    this.targetIncome,
    this.sourceDescription,
    this.linkedIncomeId,
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
    BudgetType? type,
    double? targetIncome,
    String? sourceDescription,
    String? linkedIncomeId,
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
      type: type ?? this.type,
      targetIncome: targetIncome ?? this.targetIncome,
      sourceDescription: sourceDescription ?? this.sourceDescription,
      linkedIncomeId: linkedIncomeId ?? this.linkedIncomeId,
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
    type,
    targetIncome,
    sourceDescription,
    linkedIncomeId,
  ];
}
