import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:budget_app/features/accounts/domain/entities/loan_account.dart';
import 'package:budget_app/features/accounts/domain/entities/account_transaction.dart';
import 'package:budget_app/features/accounts/domain/usecases/calculate_loan_amortization.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_event.dart';

class LoanDetailPage extends StatelessWidget {
  final LoanAccount loanAccount;

  const LoanDetailPage({super.key, required this.loanAccount});

  void _showRepaymentDialog(BuildContext context) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Repayment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Repayment Amount (\$)'),
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
                  accountId: loanAccount.account.id,
                  type: AccountTransactionType.repayment,
                  amount: amount,
                  date: DateTime.now(),
                  note: noteController.text.isNotEmpty ? noteController.text : null,
                );
                context.read<AccountBloc>().add(LogAccountTransactionEvent(tx));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final schedule = LoanAmortizationCalculator.calculate(
      principal: loanAccount.currentPrincipal,
      annualInterestRateApr: loanAccount.interestRateApr,
      monthlyPayment: loanAccount.minimumMonthlyPayment,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(loanAccount.account.name),
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
                    Text('Remaining Balance', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(
                      formatter.format(loanAccount.currentPrincipal),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('APR Rate'),
                            Text('${loanAccount.interestRateApr}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Est. Months to Payoff'),
                            Text('${schedule.totalMonthsToPayoff} months', style: const TextStyle(fontWeight: FontWeight.bold)),
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
              icon: const Icon(Icons.payment),
              label: const Text('Log Monthly Repayment'),
              onPressed: () => _showRepaymentDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
