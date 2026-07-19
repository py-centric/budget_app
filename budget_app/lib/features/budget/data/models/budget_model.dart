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
    super.type = BudgetType.regular,
    super.targetIncome,
    super.sourceDescription,
    super.linkedIncomeId,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    final typeStr = map['type'] as String? ?? 'regular';
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
      type: BudgetType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => BudgetType.regular,
      ),
      targetIncome: map['target_income'] as double?,
      sourceDescription: map['source_description'] as String?,
      linkedIncomeId: map['linked_income_id'] as String?,
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
      'type': type.name,
      'target_income': targetIncome,
      'source_description': sourceDescription,
      'linked_income_id': linkedIncomeId,
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
      type: entity.type,
      targetIncome: entity.targetIncome,
      sourceDescription: entity.sourceDescription,
      linkedIncomeId: entity.linkedIncomeId,
    );
  }
}
