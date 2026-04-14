import 'package:equatable/equatable.dart';

class BudgetComparison extends Equatable {
  final String categoryId;
  final String categoryName;
  final String? categoryIcon;
  final double plannedAmount;
  final double actualAmount;
  final int year;
  final int month;

  const BudgetComparison({
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    required this.plannedAmount,
    required this.actualAmount,
    required this.year,
    required this.month,
  });

  double get variance => plannedAmount - actualAmount;

  double get variancePercentage {
    if (plannedAmount == 0) return 0;
    return (variance / plannedAmount * 100);
  }

  double get percentageSpent {
    if (plannedAmount == 0) return 0;
    return (actualAmount / plannedAmount * 100).clamp(0, 200);
  }

  bool get isOverBudget => actualAmount > plannedAmount;

  bool get isUnderBudget => actualAmount < plannedAmount;

  bool get isOnTrack {
    if (plannedAmount == 0) return true;
    return percentageSpent <= 80;
  }

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    categoryIcon,
    plannedAmount,
    actualAmount,
    year,
    month,
  ];
}

class BudgetComparisonSummary extends Equatable {
  final double totalPlanned;
  final double totalActual;
  final double totalVariance;
  final int overBudgetCount;
  final int underBudgetCount;
  final int onTrackCount;

  const BudgetComparisonSummary({
    required this.totalPlanned,
    required this.totalActual,
    required this.totalVariance,
    required this.overBudgetCount,
    required this.underBudgetCount,
    required this.onTrackCount,
  });

  double get overallPercentageSpent {
    if (totalPlanned == 0) return 0;
    return (totalActual / totalPlanned * 100).clamp(0, 200);
  }

  bool get isOverBudget => totalActual > totalPlanned;

  @override
  List<Object?> get props => [
    totalPlanned,
    totalActual,
    totalVariance,
    overBudgetCount,
    underBudgetCount,
    onTrackCount,
  ];
}
