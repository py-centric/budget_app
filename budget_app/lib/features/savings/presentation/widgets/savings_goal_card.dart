import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/core/theme/app_spacing.dart';
import 'package:budget_app/core/utils/currency_formatter.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';
import '../bloc/savings_state.dart';
import 'savings_goal_progress_bar.dart';

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoalWithContributions goalWithContributions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddContribution;

  const SavingsGoalCard({
    super.key,
    required this.goalWithContributions,
    this.onEdit,
    this.onDelete,
    this.onAddContribution,
  });

  @override
  Widget build(BuildContext context) {
    final goal = goalWithContributions.goal;
    final theme = Theme.of(context);
    final progressPercentage = goal.progressPercentage;
    final remaining = goal.remainingAmount;
    final isOverdue = goal.isOverdue;
    final isCompleted = goal.isCompleted;
    final currencyCode = context
        .watch<SettingsBloc>()
        .state
        .settings
        .currencyCode;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: InkWell(
        onTap: onAddContribution,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getColor(goal.color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                    ),
                    child: Icon(
                      _getIcon(goal.icon),
                      size: 24,
                      color: _getColor(goal.color),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (goal.deadline != null)
                          Text(
                            _formatDeadline(goal.deadline!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isOverdue ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit?.call();
                        } else if (value == 'delete') {
                          onDelete?.call();
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SavingsGoalProgressBar(
                currentAmount: goal.currentAmount,
                targetAmount: goal.targetAmount,
                progressColor: _getColor(goal.color),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${CurrencyFormatter.format(goal.currentAmount, currencyCode: currencyCode)} / ${CurrencyFormatter.format(goal.targetAmount, currencyCode: currencyCode)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : isOverdue
                          ? theme.colorScheme.error.withValues(alpha: 0.1)
                          : progressPercentage > 80
                          ? theme.colorScheme.tertiary.withValues(alpha: 0.1)
                          : theme.colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      isCompleted
                          ? 'Completed!'
                          : isOverdue
                          ? 'Overdue'
                          : '${progressPercentage.toStringAsFixed(0)}% - ${CurrencyFormatter.format(remaining, currencyCode: currencyCode)} left',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isCompleted
                            ? theme.colorScheme.primary
                            : isOverdue
                            ? theme.colorScheme.error
                            : progressPercentage > 80
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (goal.linkedCategoryId != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.link, size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Linked to category',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'savings':
        return Icons.savings;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'flight':
        return Icons.flight;
      case 'home':
        return Icons.home;
      case 'directions_car':
        return Icons.directions_car;
      case 'school':
        return Icons.school;
      case 'celebration':
        return Icons.celebration;
      case 'shopping_bag':
        return Icons.shopping_bag;
      default:
        return Icons.savings;
    }
  }

  Color _getColor(String? colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return 'Overdue by ${-difference.inDays} days';
    } else if (difference.inDays == 0) {
      return 'Due today';
    } else if (difference.inDays == 1) {
      return 'Due tomorrow';
    } else if (difference.inDays < 7) {
      return 'Due in ${difference.inDays} days';
    } else if (difference.inDays < 30) {
      return 'Due in ${(difference.inDays / 7).floor()} weeks';
    } else {
      return 'Due ${deadline.month}/${deadline.day}/${deadline.year}';
    }
  }
}
