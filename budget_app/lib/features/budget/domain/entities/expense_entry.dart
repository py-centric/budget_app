import 'package:equatable/equatable.dart';

/// A single expense transaction within a budget period.
/// Records money spent or committed, categorized for tracking and summary.
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
  final String? accountId;
  final String? accountName;
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
    this.accountId,
    this.accountName,
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
      accountId: map['account_id'] as String?,
      accountName: map['account_name'] as String?,
      isPotential: (map['is_potential'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'budget_id': budgetId,
      'amount': amount,
      'category_id': categoryId,
      'description': description,
      'date': date.toIso8601String(),
      'period_month': periodMonth ?? date.month,
      'period_year': periodYear ?? date.year,
      'account_id': accountId,
      'is_potential': isPotential ? 1 : 0,
    };
  }

  ExpenseEntry copyWith({
    String? id,
    String? budgetId,
    double? amount,
    String? categoryId,
    String? description,
    DateTime? date,
    int? periodMonth,
    int? periodYear,
    String? categoryName,
    String? categoryIcon,
    String? accountId,
    String? accountName,
    bool? isPotential,
    bool clearAccount = false,
  }) {
    return ExpenseEntry(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      date: date ?? this.date,
      periodMonth: periodMonth ?? this.periodMonth,
      periodYear: periodYear ?? this.periodYear,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      accountId: clearAccount ? null : (accountId ?? this.accountId),
      accountName: clearAccount ? null : (accountName ?? this.accountName),
      isPotential: isPotential ?? this.isPotential,
    );
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
    accountId,
    accountName,
    isPotential,
  ];
}
