import 'package:flutter/material.dart';
import '../../domain/entities/budget_comparison.dart';

class BudgetComparisonTable extends StatelessWidget {
  final List<BudgetComparison> comparisons;
  final BudgetComparisonSummary summary;
  final VoidCallback? onCategoryTap;

  const BudgetComparisonTable({
    super.key,
    required this.comparisons,
    required this.summary,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (comparisons.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No budget comparisons available'),
        ),
      );
    }

    return Column(
      children: [
        _buildSummaryRow(context),
        const Divider(),
        _buildHeaderRow(context),
        const Divider(thickness: 2),
        Expanded(
          child: ListView.separated(
            itemCount: comparisons.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _ComparisonRow(
                comparison: comparisons[index],
                onTap: onCategoryTap,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context) {
    final isOverBudget = summary.totalActual > summary.totalPlanned;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOverBudget
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            label: 'Total Planned',
            value: '\$${summary.totalPlanned.toStringAsFixed(0)}',
            color: Colors.blue,
          ),
          _SummaryItem(
            label: 'Total Spent',
            value: '\$${summary.totalActual.toStringAsFixed(0)}',
            color: isOverBudget ? Colors.red : Colors.green,
          ),
          _SummaryItem(
            label: 'Variance',
            value:
                '${summary.totalVariance >= 0 ? '+' : ''}\$${summary.totalVariance.toStringAsFixed(0)}',
            color: summary.totalVariance >= 0 ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Category',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Planned',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Actual',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Status',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final BudgetComparison comparison;
  final VoidCallback? onTap;

  const _ComparisonRow({required this.comparison, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (comparison.isOverBudget) {
      statusColor = Colors.red;
      statusText = '${comparison.percentageSpent.toStringAsFixed(0)}%';
      statusIcon = Icons.arrow_upward;
    } else if (comparison.isOnTrack) {
      statusColor = Colors.green;
      statusText = '${comparison.percentageSpent.toStringAsFixed(0)}%';
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.orange;
      statusText = '${comparison.percentageSpent.toStringAsFixed(0)}%';
      statusIcon = Icons.warning;
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(comparison.categoryIcon),
                    size: 20,
                    color: statusColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      comparison.categoryName,
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '\$${comparison.plannedAmount.toStringAsFixed(0)}',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '\$${comparison.actualAmount.toStringAsFixed(0)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: comparison.isOverBudget ? Colors.red : null,
                  fontWeight: comparison.isOverBudget ? FontWeight.bold : null,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 2),
                    Text(
                      statusText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
