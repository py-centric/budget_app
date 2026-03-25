import '../../domain/entities/budget.dart';

class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.name,
    required super.periodMonth,
    required super.periodYear,
    super.isActive = true,
    super.currencyCode,
    super.targetCurrencyCode,
    super.exchangeRate,
    super.convertedAmount,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      name: map['name'] as String,
      periodMonth: map['period_month'] as int,
      periodYear: map['period_year'] as int,
      isActive: (map['is_active'] as int) == 1,
      currencyCode: map['currency_code'] as String?,
      targetCurrencyCode: map['target_currency_code'] as String?,
      exchangeRate: map['exchange_rate'] as double?,
      convertedAmount: map['converted_amount'] as double?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'period_month': periodMonth,
      'period_year': periodYear,
      'is_active': isActive ? 1 : 0,
      'currency_code': currencyCode,
      'target_currency_code': targetCurrencyCode,
      'exchange_rate': exchangeRate,
      'converted_amount': convertedAmount,
    };
  }

  factory BudgetModel.fromEntity(Budget entity) {
    return BudgetModel(
      id: entity.id,
      name: entity.name,
      periodMonth: entity.periodMonth,
      periodYear: entity.periodYear,
      isActive: entity.isActive,
      currencyCode: entity.currencyCode,
      targetCurrencyCode: entity.targetCurrencyCode,
      exchangeRate: entity.exchangeRate,
      convertedAmount: entity.convertedAmount,
    );
  }
}
