import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:budget_app/features/accounts/domain/entities/savings_account.dart';
import 'package:budget_app/features/accounts/domain/entities/account_transaction.dart';
import 'package:budget_app/features/accounts/domain/usecases/calculate_savings_growth.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_event.dart';

class SavingsDetailPage extends StatelessWidget {
  final SavingsAccount savingsAccount;

  const SavingsDetailPage({super.key, required this.savingsAccount});

  void _showContributionDialog(BuildContext context) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Savings Contribution'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Contribution Amount (\$)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note (Optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount > 0) {
                final tx = AccountTransaction(
                  id: const Uuid().v4(),
                  accountId: savingsAccount.account.id,
                  type: AccountTransactionType.contribution,
                  amount: amount,
                  date: DateTime.now(),
                  note: noteController.text.isNotEmpty ? noteController.text : null,
                );
                context.read<AccountBloc>().add(LogAccountTransactionEvent(tx));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Confirm Deposit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final projection = SavingsGrowthCalculator.calculateProjectedGrowth(
      initialBalance: savingsAccount.account.balance,
      monthlyContribution: 100.0,
      annualInterestRateApy: savingsAccount.interestRateApy,
      durationInMonths: 12,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(savingsAccount.account.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Current Savings Balance', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(
                      formatter.format(savingsAccount.account.balance),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('APY Rate'),
                            Text('${savingsAccount.interestRateApy}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('1-Yr Est. Interest'),
                            Text(formatter.format(projection.totalInterestEarned), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.add_circle),
              label: const Text('Log Deposit Contribution'),
              onPressed: () => _showContributionDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
