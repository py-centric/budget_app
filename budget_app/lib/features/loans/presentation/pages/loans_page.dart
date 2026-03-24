import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:budget_app/features/loans/domain/entities/loan.dart';
import 'package:budget_app/features/loans/domain/entities/loan_summary.dart';
import 'package:budget_app/features/loans/presentation/bloc/loan_bloc.dart';
import 'package:budget_app/features/loans/presentation/bloc/loan_state.dart';
import 'package:budget_app/features/loans/presentation/pages/loan_detail_page.dart';
import 'package:budget_app/features/loans/presentation/pages/add_loan_page.dart';

class LoansPage extends StatelessWidget {
  const LoansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loans')),
      body: BlocBuilder<LoanBloc, LoanState>(
        builder: (context, state) {
          if (state is LoanLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LoanError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is LoanLoaded) {
            return Column(
              children: [
                if (state.summary != null)
                  _buildSummaryCard(context, state.summary!),
                Expanded(
                  child: state.loans.isEmpty
                      ? _buildEmptyState(context)
                      : _buildLoansList(context, state.loans),
                ),
              ],
            );
          }

          return const Center(child: Text('No loans yet'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewLoan(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, LoanSummary summary) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Outstanding',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(summary.totalOutstanding),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusChip(
                  context,
                  'Outstanding',
                  summary.outstandingCount,
                  Colors.orange,
                ),
                _buildStatusChip(
                  context,
                  'Partial',
                  summary.partialCount,
                  Colors.blue,
                ),
                _buildStatusChip(
                  context,
                  'Settled',
                  summary.settledCount,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text('No loans yet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first loan',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoansList(BuildContext context, List<Loan> loans) {
    return ListView.builder(
      itemCount: loans.length,
      itemBuilder: (context, index) {
        final loan = loans[index];
        return _buildLoanTile(context, loan);
      },
    );
  }

  Widget _buildLoanTile(BuildContext context, Loan loan) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat.yMMMd();

    Color statusColor;
    switch (loan.status) {
      case LoanStatus.outstanding:
        statusColor = Colors.orange;
        break;
      case LoanStatus.partial:
        statusColor = Colors.blue;
        break;
      case LoanStatus.settled:
        statusColor = Colors.green;
        break;
    }

    return ListTile(
      title: Text(loan.borrowerName),
      subtitle: Text(
        '${dateFormat.format(loan.loanDate)} • ${loan.status.displayName}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            currencyFormat.format(loan.remainingBalance),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (loan.remainingBalance < loan.loanAmount)
            Text(
              'of ${currencyFormat.format(loan.loanAmount)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
        ],
      ),
      leading: CircleAvatar(
        backgroundColor: statusColor.withValues(alpha: 0.1),
        child: Icon(
          loan.status == LoanStatus.settled ? Icons.check : Icons.person,
          color: statusColor,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoanDetailPage(loanId: loan.id),
          ),
        );
      },
    );
  }

  void _addNewLoan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddLoanPage()),
    );
  }
}
