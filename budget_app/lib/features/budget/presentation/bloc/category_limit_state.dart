import 'package:equatable/equatable.dart';
import '../../domain/entities/category_limit.dart';

class CategoryLimitWithSpending {
  final CategoryLimit limit;
  final double spentAmount;
  final String categoryName;
  final String? categoryIcon;

  const CategoryLimitWithSpending({
    required this.limit,
    required this.spentAmount,
    required this.categoryName,
    this.categoryIcon,
  });

  double get progressPercentage {
    if (limit.amount == 0) return 0;
    return (spentAmount / limit.amount * 100).clamp(0, 100);
  }

  double get remainingAmount =>
      (limit.amount - spentAmount).clamp(0, double.infinity);

  bool get isOverBudget => spentAmount > limit.amount;
}

abstract class CategoryLimitState extends Equatable {
  const CategoryLimitState();

  @override
  List<Object?> get props => [];
}

class CategoryLimitInitial extends CategoryLimitState {}

class CategoryLimitLoading extends CategoryLimitState {}

class CategoryLimitLoaded extends CategoryLimitState {
  final List<CategoryLimitWithSpending> limits;
  final int year;
  final int month;

  const CategoryLimitLoaded({
    required this.limits,
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [limits, year, month];
}

class CategoryLimitError extends CategoryLimitState {
  final String message;

  const CategoryLimitError(this.message);

  @override
  List<Object?> get props => [message];
}
