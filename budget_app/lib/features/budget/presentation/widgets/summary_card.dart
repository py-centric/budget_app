import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

    return Column(
      children: [
        if (summary.missedPotentialCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Material(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.orange.shade200),
                ),
                leading: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
                title: Text(
                  '${summary.missedPotentialCount} past-due potential transactions',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Budget Summary',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryItem(
                      label: 'Income',
                      actualAmount: summary.totalIncome,
                      projectedAmount: summary.totalPotentialIncome,
                      color: Colors.green,
                      icon: Icons.arrow_downward,
                      currencyCode: currencyCode,
                    ),
                    _SummaryItem(
                      label: 'Expenses',
                      actualAmount: summary.totalExpenses,
                      projectedAmount: summary.totalPotentialExpenses,
                      color: Colors.red,
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
              color: isPositive ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text('Balance', style: Theme.of(context).textTheme.titleMedium),
            Text(
              CurrencyFormatter.format(
                actualBalance,
                currencyCode: currencyCode,
              ),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (hasProjection) ...[
              const SizedBox(height: 8),
              Text(
                'Projected: ${projectedIsPositive ? '+' : ''}${CurrencyFormatter.format(projectedBalance, currencyCode: currencyCode)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: projectedIsPositive ? Colors.green : Colors.red,
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
