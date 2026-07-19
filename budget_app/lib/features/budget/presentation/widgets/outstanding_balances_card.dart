import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/core/theme/app_spacing.dart';
import 'package:budget_app/core/utils/currency_formatter.dart';
import 'package:budget_app/features/budget/domain/usecases/calculate_summary.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';

class OutstandingBalancesCard extends StatelessWidget {
  final BudgetSummary summary;

  const OutstandingBalancesCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final currencyCode =
        context.watch<SettingsBloc>().state.settings.currencyCode;
    final theme = Theme.of(context);

    final outstandingIncome =
        summary.totalPotentialIncome - summary.totalIncome;
    final outstandingExpenses =
        summary.totalPotentialExpenses - summary.totalExpenses;
    final netOutstanding = outstandingIncome - outstandingExpenses;

    if (outstandingIncome.abs() < 0.01 && outstandingExpenses.abs() < 0.01) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pending_actions,
                  color: theme.colorScheme.tertiary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Outstanding Balances',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (outstandingIncome > 0.01)
              _OutstandingRow(
                label: 'Income to Receive',
                amount: outstandingIncome,
                currencyCode: currencyCode,
                icon: Icons.arrow_downward,
                color: theme.colorScheme.primary,
              ),
            if (outstandingExpenses > 0.01) ...[
              if (outstandingIncome > 0.01) const SizedBox(height: AppSpacing.sm),
              _OutstandingRow(
                label: 'Expenses to Pay',
                amount: outstandingExpenses,
                currencyCode: currencyCode,
                icon: Icons.arrow_upward,
                color: theme.colorScheme.error,
              ),
            ],
            if (outstandingIncome > 0.01 && outstandingExpenses > 0.01) ...[
              const Divider(height: AppSpacing.lg),
              _OutstandingRow(
                label: 'Net Outstanding',
                amount: netOutstanding,
                currencyCode: currencyCode,
                icon: netOutstanding >= 0
                    ? Icons.trending_up
                    : Icons.trending_down,
                color: netOutstanding >= 0
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                isBold: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OutstandingRow extends StatelessWidget {
  final String label;
  final double amount;
  final String currencyCode;
  final IconData icon;
  final Color color;
  final bool isBold;

  const _OutstandingRow({
    required this.label,
    required this.amount,
    required this.currencyCode,
    required this.icon,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          CurrencyFormatter.format(amount, currencyCode: currencyCode),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
