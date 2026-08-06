import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budget_app/features/accounts/domain/entities/savings_account.dart';

class SavingsAccountCard extends StatelessWidget {
  final SavingsAccount savingsAccount;
  final VoidCallback onTap;

  const SavingsAccountCard({
    super.key,
    required this.savingsAccount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final goalProgress = savingsAccount.targetGoalAmount != null && savingsAccount.targetGoalAmount! > 0
        ? (savingsAccount.account.balance / savingsAccount.targetGoalAmount!).clamp(0.0, 1.0)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          child: Icon(Icons.savings, color: colorScheme.onSecondaryContainer),
        ),
        title: Text(
          savingsAccount.account.name,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('APY: ${savingsAccount.interestRateApy.toStringAsFixed(2)}% (${savingsAccount.compoundingFrequency.name})'),
            if (goalProgress != null) ...[
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: goalProgress,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: colorScheme.primary,
              ),
            ],
          ],
        ),
        trailing: Text(
          formatter.format(savingsAccount.account.balance),
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
