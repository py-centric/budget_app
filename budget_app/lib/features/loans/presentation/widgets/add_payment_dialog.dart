import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:budget_app/features/loans/domain/entities/loan_payment.dart';
import 'package:budget_app/features/loans/presentation/bloc/loan_bloc.dart';
import 'package:budget_app/features/loans/presentation/bloc/loan_event.dart';

class AddPaymentDialog extends StatefulWidget {
  final String loanId;
  final double remainingBalance;

  const AddPaymentDialog({
    super.key,
    required this.loanId,
    required this.remainingBalance,
  });

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime _paymentDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return AlertDialog(
      title: const Text('Add Payment'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remaining balance: ${currencyFormat.format(widget.remainingBalance)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Payment Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter payment amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid positive amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Payment Date'),
              subtitle: Text(DateFormat.yMMMd().format(_paymentDate)),
              onTap: _selectDate,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _savePayment, child: const Text('Save')),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _paymentDate = picked;
      });
    }
  }

  void _savePayment() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final payment = LoanPayment(
        id: 'payment_${now.millisecondsSinceEpoch}',
        loanId: widget.loanId,
        amount: double.parse(_amountController.text),
        paymentDate: _paymentDate,
        createdAt: now,
      );

      context.read<LoanBloc>().add(AddPayment(payment));
      Navigator.pop(context);
    }
  }
}
