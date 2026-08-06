import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budget_app/features/accounts/domain/entities/loan_account.dart';

class LoanAccountCard extends StatelessWidget {
  final LoanAccount loanAccount;
  final VoidCallback onTap;

  const LoanAccountCard({
    super.key,
    required this.loanAccount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final progress = loanAccount.originalPrincipal > 0
        ? (1.0 - (loanAccount.currentPrincipal / loanAccount.originalPrincipal)).clamp(0.0, 1.0)
        : 1.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: colorScheme.errorContainer,
          child: Icon(Icons.money_off, color: colorScheme.onErrorContainer),
        ),
        title: Text(
          loanAccount.account.name,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('APR: ${loanAccount.interestRateApr.toStringAsFixed(1)}% | Min Pay: ${formatter.format(loanAccount.minimumMonthlyPayment)}'),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: Colors.green,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatter.format(loanAccount.currentPrincipal),
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (loanAccount.isPaidOff)
              Text(
                'PAID OFF',
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
