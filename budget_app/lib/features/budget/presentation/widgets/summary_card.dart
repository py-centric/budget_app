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
    final isPositive = summary.balance >= 0;
    final currencyCode = context.watch<SettingsBloc>().state.settings.currencyCode;

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
                leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                title: Text(
                  '${summary.missedPotentialCount} past-due potential transactions',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                subtitle: const Text('Confirm or delete these hypothetical items.'),
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
                      amount: summary.totalIncome,
                      color: Colors.green,
                      icon: Icons.arrow_downward,
                      currencyCode: currencyCode,
                    ),
                    _SummaryItem(
                      label: 'Expenses',
                      amount: summary.totalExpenses,
                      color: Colors.red,
                      icon: Icons.arrow_upward,
                      currencyCode: currencyCode,
                    ),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.sentiment_satisfied
                          : Icons.sentiment_dissatisfied,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        Text(
                          'Balance',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          CurrencyFormatter.format(summary.balance, currencyCode: currencyCode),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: isPositive ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final String currencyCode;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          CurrencyFormatter.format(amount, currencyCode: currencyCode),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
