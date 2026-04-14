import 'package:equatable/equatable.dart';
import '../../domain/entities/category_limit.dart';

abstract class CategoryLimitEvent extends Equatable {
  const CategoryLimitEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategoryLimits extends CategoryLimitEvent {
  final String budgetId;
  final int year;
  final int month;

  const LoadCategoryLimits({
    required this.budgetId,
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [budgetId, year, month];
}

class AddCategoryLimit extends CategoryLimitEvent {
  final String categoryId;
  final double amount;
  final LimitPeriod period;
  final String budgetId;

  const AddCategoryLimit({
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.budgetId,
  });

  @override
  List<Object?> get props => [categoryId, amount, period, budgetId];
}

class UpdateCategoryLimit extends CategoryLimitEvent {
  final CategoryLimit limit;

  const UpdateCategoryLimit(this.limit);

  @override
  List<Object?> get props => [limit];
}

class DeleteCategoryLimit extends CategoryLimitEvent {
  final String limitId;

  const DeleteCategoryLimit(this.limitId);

  @override
  List<Object?> get props => [limitId];
}
