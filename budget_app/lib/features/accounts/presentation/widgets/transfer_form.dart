import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/accounts/domain/entities/transfer.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_event.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_state.dart';

class TransferForm extends StatefulWidget {
  const TransferForm({super.key});

  @override
  State<TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends State<TransferForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  Account? _fromAccount;
  Account? _toAccount;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        List<Account> accounts = [];
        if (state is AccountLoaded) {
          accounts = state.accounts;
        } else if (state is TransferSuccess) {
          accounts = state.accounts;
        } else if (state is TransferError) {
          accounts = state.accounts;
        }

        if (accounts.length < 2) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Transfer Between Accounts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                const Text('You need at least 2 accounts to make a transfer.'),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }

        _fromAccount ??= accounts.first;
        _toAccount ??= accounts.length > 1 ? accounts[1] : accounts.first;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Transfer Between Accounts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'From Account',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButton<Account>(
                    value: _fromAccount,
                    isDense: true,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: accounts.map((account) {
                      return DropdownMenuItem(
                        value: account,
                        child: Text(
                          '${account.name} (\$${account.balance.toStringAsFixed(2)})',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _fromAccount = value);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'To Account',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButton<Account>(
                    value: _toAccount,
                    isDense: true,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: accounts.map((account) {
                      return DropdownMenuItem(
                        value: account,
                        child: Text(
                          '${account.name} (\$${account.balance.toStringAsFixed(2)})',
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _toAccount = value);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid positive amount';
                    }
                    if (_fromAccount != null &&
                        amount > _fromAccount!.balance) {
                      return 'Amount exceeds available balance';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _createTransfer,
                  child: const Text('Transfer'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _createTransfer() {
    if (_formKey.currentState!.validate() &&
        _fromAccount != null &&
        _toAccount != null) {
      final transfer = Transfer(
        id: const Uuid().v4(),
        fromAccountId: _fromAccount!.id,
        toAccountId: _toAccount!.id,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        createdAt: DateTime.now(),
      );

      context.read<AccountBloc>().add(
        CreateTransfer(
          transfer: transfer,
          fromAccountId: _fromAccount!.id,
          toAccountId: _toAccount!.id,
        ),
      );

      Navigator.pop(context);
    }
  }
}
