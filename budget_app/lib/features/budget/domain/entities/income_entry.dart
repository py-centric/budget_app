import 'package:equatable/equatable.dart';

class IncomeEntry extends Equatable {
  final String id;
  final String budgetId;
  final double amount;
  final String? description;
  final DateTime date;
  final int? periodMonth;
  final int? periodYear;
  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final bool isPotential;

  const IncomeEntry({
    required this.id,
    required this.budgetId,
    required this.amount,
    this.description,
    required this.date,
    this.periodMonth,
    this.periodYear,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.isPotential = false,
  });

  factory IncomeEntry.fromMap(Map<String, dynamic> map) {
    return IncomeEntry(
      id: map['id'] as String,
      budgetId: map['budget_id'] as String? ?? 'default', // Fallback for legacy
      amount: map['amount'] as double,
      description: map['description'] as String?,
      date: DateTime.parse(map['date'] as String),
      periodMonth: map['period_month'] as int?,
      periodYear: map['period_year'] as int?,
      categoryId: map['category_id'] as String?,
      categoryName: map['category_name'] as String?,
      categoryIcon: map['category_icon'] as String?,
      isPotential: (map['is_potential'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'budget_id': budgetId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'period_month': periodMonth ?? date.month,
      'period_year': periodYear ?? date.year,
      'category_id': categoryId,
      'is_potential': isPotential ? 1 : 0,
    };
  }

  @override
  List<Object?> get props => [
        id,
        budgetId,
        amount,
        description,
        date,
        periodMonth,
        periodYear,
        categoryId,
        categoryName,
        categoryIcon,
        isPotential,
      ];
}
