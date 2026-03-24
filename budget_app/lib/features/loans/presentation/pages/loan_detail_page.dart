import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:budget_app/features/loans/domain/entities/loan.dart';
import 'package:budget_app/features/loans/domain/entities/loan_payment.dart';
import 'package:budget_app/features/loans/domain/repositories/loan_repository.dart';
import 'package:budget_app/features/loans/presentation/bloc/loan_bloc.dart';
import 'package:budget_app/features/loans/presentation/bloc/loan_event.dart';
import 'package:budget_app/features/loans/presentation/bloc/loan_state.dart';
import 'package:budget_app/features/loans/presentation/pages/add_loan_page.dart';
import 'package:budget_app/features/loans/presentation/widgets/add_payment_dialog.dart';

class LoanDetailPage extends StatefulWidget {
  final String loanId;

  const LoanDetailPage({super.key, required this.loanId});

  @override
  State<LoanDetailPage> createState() => _LoanDetailPageState();
}

class _LoanDetailPageState extends State<LoanDetailPage> {
  Loan? _loan;
  List<LoanPayment> _payments = [];
  double _totalPaid = 0;

  @override
  void initState() {
    super.initState();
    _loadLoanData();
  }

  Future<void> _loadLoanData() async {
    final repository = context.read<LoanRepository>();
    final loan = await repository.getLoanById(widget.loanId);
    if (loan != null) {
      final payments = await repository.getPaymentsForLoan(widget.loanId);
      final totalPaid = await repository.getTotalPaymentsForLoan(widget.loanId);
      if (mounted) {
        setState(() {
          _loan = loan;
          _payments = payments;
          _totalPaid = totalPaid;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loan Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat.yMMMd();

    Color statusColor;
    switch (_loan!.status) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editLoan(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteLoan(context),
          ),
        ],
      ),
      body: BlocListener<LoanBloc, LoanState>(
        listener: (context, state) {
          if (state is LoanLoaded) {
            _loadLoanData();
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: statusColor.withValues(alpha: 0.1),
                          child: Icon(Icons.person, color: statusColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _loan!.borrowerName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                dateFormat.format(_loan!.loanDate),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _loan!.status.displayName,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildAmountRow(
                      context,
                      'Loan Amount',
                      currencyFormat.format(_loan!.loanAmount),
                    ),
                    const Divider(height: 24),
                    _buildAmountRow(
                      context,
                      'Total Paid',
                      currencyFormat.format(_totalPaid),
                    ),
                    const Divider(height: 24),
                    _buildAmountRow(
                      context,
                      'Remaining Balance',
                      currencyFormat.format(_loan!.remainingBalance),
                      isHighlighted: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment History',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_loan!.status != LoanStatus.settled)
                  TextButton.icon(
                    onPressed: () => _addPayment(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Payment'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_payments.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No payments yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ),
              )
            else
              ..._payments.map(
                (payment) => _buildPaymentTile(context, payment),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(
    BuildContext context,
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Text(
          value,
          style: isHighlighted
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                )
              : Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildPaymentTile(BuildContext context, LoanPayment payment) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat.yMMMd();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.payment)),
        title: Text(currencyFormat.format(payment.amount)),
        subtitle: Text(dateFormat.format(payment.paymentDate)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _deletePayment(context, payment),
        ),
      ),
    );
  }

  void _editLoan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddLoanPage(existingLoan: _loan)),
    ).then((_) => _loadLoanData());
  }

  void _deleteLoan(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Loan'),
        content: const Text('Are you sure you want to delete this loan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<LoanBloc>().add(DeleteLoan(_loan!.id));
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addPayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AddPaymentDialog(
        loanId: widget.loanId,
        remainingBalance: _loan!.remainingBalance,
      ),
    ).then((_) => _loadLoanData());
  }

  void _deletePayment(BuildContext context, LoanPayment payment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Payment'),
        content: const Text('Are you sure you want to delete this payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<LoanBloc>().add(
                DeletePayment(payment.id, payment.loanId),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
