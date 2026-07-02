import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/core/theme/app_spacing.dart';
import 'package:budget_app/core/utils/currency_formatter.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';
import '../../domain/entities/category_limit.dart';
import '../bloc/category_limit_state.dart';
import 'category_limit_progress_bar.dart';

class CategoryLimitCard extends StatelessWidget {
  final CategoryLimitWithSpending limitWithSpending;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CategoryLimitCard({
    super.key,
    required this.limitWithSpending,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final limit = limitWithSpending.limit;
    final theme = Theme.of(context);
    final percentUsed = limitWithSpending.progressPercentage;
    final remaining = limitWithSpending.remainingAmount;
    final isOverBudget = limitWithSpending.isOverBudget;
    final currencyCode = context
        .watch<SettingsBloc>()
        .state
        .settings
        .currencyCode;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(limitWithSpending.categoryIcon),
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: AppSpacing.sm + AppSpacing.xs),
                  Expanded(
                    child: Text(
                      limitWithSpending.categoryName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: onDelete,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              SizedBox(height: AppSpacing.sm + AppSpacing.xs),
              CategoryLimitProgressBar(
                spentAmount: limitWithSpending.spentAmount,
                limitAmount: limit.amount,
              ),
              SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${CurrencyFormatter.format(limitWithSpending.spentAmount, currencyCode: currencyCode)} / ${CurrencyFormatter.format(limit.amount, currencyCode: currencyCode)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isOverBudget
                          ? theme.colorScheme.error.withValues(alpha: 0.1)
                          : percentUsed > 80
                          ? theme.colorScheme.tertiary.withValues(alpha: 0.1)
                          : theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      isOverBudget
                          ? 'Over by ${CurrencyFormatter.format(limitWithSpending.spentAmount - limit.amount, currencyCode: currencyCode)}'
                          : '${CurrencyFormatter.format(remaining, currencyCode: currencyCode)} left',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isOverBudget
                            ? theme.colorScheme.error
                            : percentUsed > 80
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                limit.period == LimitPeriod.monthly ? 'Monthly' : 'Weekly',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'movie':
        return Icons.movie;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      default:
        return Icons.category;
    }
  }
}
