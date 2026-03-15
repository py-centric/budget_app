import '../../domain/entities/budget.dart';

class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.name,
    required super.periodMonth,
    required super.periodYear,
    super.isActive = true,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      name: map['name'] as String,
      periodMonth: map['period_month'] as int,
      periodYear: map['period_year'] as int,
      isActive: (map['is_active'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'period_month': periodMonth,
      'period_year': periodYear,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory BudgetModel.fromEntity(Budget entity) {
    return BudgetModel(
      id: entity.id,
      name: entity.name,
      periodMonth: entity.periodMonth,
      periodYear: entity.periodYear,
      isActive: entity.isActive,
    );
  }
}
