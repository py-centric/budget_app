import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/core/theme/app_spacing.dart';
import 'package:budget_app/features/budget/domain/usecases/calculate_summary.dart';
import 'package:budget_app/core/utils/currency_formatter.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';

class SummaryCard extends StatelessWidget {
  final BudgetSummary summary;

  const SummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final currencyCode = context
        .watch<SettingsBloc>()
        .state
        .settings
        .currencyCode;

    final theme = Theme.of(context);

    return Column(
      children: [
        if (summary.missedPotentialCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Material(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  side: BorderSide(color: theme.colorScheme.tertiary.withValues(alpha: 0.3)),
                ),
                leading: Icon(
                  Icons.warning_amber_rounded,
                  color: theme.colorScheme.tertiary,
                ),
                title: Text(
                  '${summary.missedPotentialCount} past-due potential transactions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                subtitle: const Text(
                  'Confirm or delete these hypothetical items.',
                ),
              ),
            ),
          ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Text(
                  'Budget Summary',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryItem(
                      label: 'Income',
                      actualAmount: summary.totalIncome,
                      projectedAmount: summary.totalPotentialIncome,
                      color: Theme.of(context).colorScheme.primary,
                      icon: Icons.arrow_downward,
                      currencyCode: currencyCode,
                    ),
                    _SummaryItem(
                      label: 'Expenses',
                      actualAmount: summary.totalExpenses,
                      projectedAmount: summary.totalPotentialExpenses,
                      color: Theme.of(context).colorScheme.error,
                      icon: Icons.arrow_upward,
                      currencyCode: currencyCode,
                    ),
                  ],
                ),
                const Divider(height: 32),
                _BalanceDisplay(
                  actualBalance: summary.balance,
                  projectedBalance:
                      summary.totalPotentialIncome -
                      summary.totalPotentialExpenses,
                  currencyCode: currencyCode,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BalanceDisplay extends StatelessWidget {
  final double actualBalance;
  final double projectedBalance;
  final String currencyCode;

  const _BalanceDisplay({
    required this.actualBalance,
    required this.projectedBalance,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = actualBalance >= 0;
    final projectedIsPositive = projectedBalance >= 0;
    final hasProjection = (projectedBalance - actualBalance).abs() > 0.01;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isPositive
                  ? Icons.sentiment_satisfied
                  : Icons.sentiment_dissatisfied,
              color: isPositive ? theme.colorScheme.primary : theme.colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Balance', style: theme.textTheme.titleMedium),
            Text(
              CurrencyFormatter.format(
                actualBalance,
                currencyCode: currencyCode,
              ),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: isPositive ? theme.colorScheme.primary : theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (hasProjection) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Projected: ${projectedIsPositive ? '+' : ''}${CurrencyFormatter.format(projectedBalance, currencyCode: currencyCode)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: projectedIsPositive ? theme.colorScheme.primary : theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double actualAmount;
  final double projectedAmount;
  final Color color;
  final IconData icon;
  final String currencyCode;

  const _SummaryItem({
    required this.label,
    required this.actualAmount,
    required this.projectedAmount,
    required this.color,
    required this.icon,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final hasProjection = (projectedAmount - actualAmount).abs() > 0.01;

    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          CurrencyFormatter.format(actualAmount, currencyCode: currencyCode),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (hasProjection) ...[
          const SizedBox(height: 2),
          Text(
            '(${projectedAmount >= 0 ? '+' : ''}${CurrencyFormatter.format(projectedAmount, currencyCode: currencyCode)})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }
}
