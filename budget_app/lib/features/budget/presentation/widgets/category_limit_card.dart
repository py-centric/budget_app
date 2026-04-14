import 'package:flutter/material.dart';
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                  const SizedBox(width: 12),
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
              const SizedBox(height: 12),
              CategoryLimitProgressBar(
                spentAmount: limitWithSpending.spentAmount,
                limitAmount: limit.amount,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${limitWithSpending.spentAmount.toStringAsFixed(2)} / \$${limit.amount.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isOverBudget
                          ? Colors.red.withValues(alpha: 0.1)
                          : percentUsed > 80
                          ? Colors.orange.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isOverBudget
                          ? 'Over by \$${(limitWithSpending.spentAmount - limit.amount).toStringAsFixed(2)}'
                          : '\$${remaining.toStringAsFixed(2)} left',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isOverBudget
                            ? Colors.red
                            : percentUsed > 80
                            ? Colors.orange
                            : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                limit.period == LimitPeriod.monthly ? 'Monthly' : 'Weekly',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
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
