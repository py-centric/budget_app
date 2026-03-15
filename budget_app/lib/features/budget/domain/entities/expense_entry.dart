import 'package:equatable/equatable.dart';

class ExpenseEntry extends Equatable {
  final String id;
  final String budgetId;
  final double amount;
  final String categoryId;
  final String? description;
  final DateTime date;
  final int? periodMonth;
  final int? periodYear;
  final String? categoryName;
  final String? categoryIcon;
  final bool isPotential;

  const ExpenseEntry({
    required this.id,
    required this.budgetId,
    required this.amount,
    required this.categoryId,
    this.description,
    required this.date,
    this.periodMonth,
    this.periodYear,
    this.categoryName,
    this.categoryIcon,
    this.isPotential = false,
  });

  factory ExpenseEntry.fromMap(Map<String, dynamic> map) {
    return ExpenseEntry(
      id: map['id'] as String,
      budgetId: map['budget_id'] as String? ?? 'default', // Fallback for legacy
      amount: map['amount'] as double,
      categoryId: map['category_id'] as String? ?? map['category'] as String,
      description: map['description'] as String?,
      date: DateTime.parse(map['date'] as String),
      periodMonth: map['period_month'] as int?,
      periodYear: map['period_year'] as int?,
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
      'category': categoryId, // Satisfy legacy NOT NULL constraint
      'category_id': categoryId,
      'description': description,
      'date': date.toIso8601String(),
      'period_month': periodMonth ?? date.month,
      'period_year': periodYear ?? date.year,
      'is_potential': isPotential ? 1 : 0,
    };
  }

  @override
  List<Object?> get props => [
        id,
        budgetId,
        amount,
        categoryId,
        description,
        date,
        periodMonth,
        periodYear,
        categoryName,
        categoryIcon,
        isPotential,
      ];
}
