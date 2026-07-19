import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:budget_app/features/budget/domain/entities/recurring_transaction.dart';
import 'package:budget_app/features/budget/domain/repositories/recurring_repository.dart';
import '../bloc/reminder_bloc.dart';
import '../bloc/reminder_event.dart';

class CreateReminderDialog extends StatefulWidget {
  const CreateReminderDialog({super.key});

  @override
  State<CreateReminderDialog> createState() => _CreateReminderDialogState();
}

class _CreateReminderDialogState extends State<CreateReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  List<RecurringTransaction> _recurringTransactions = [];
  RecurringTransaction? _selectedTransaction;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  int _daysBeforeDue = 3;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecurringTransactions();
  }

  Future<void> _loadRecurringTransactions() async {
    try {
      final repository = context.read<RecurringRepository>();
      final transactions = await repository.getAllRecurringTransactions();
      if (mounted) {
        setState(() {
          _recurringTransactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _dueDate = picked);
    }
  }

  void _onCreate() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTransaction == null) return;

    context.read<ReminderBloc>().add(
          CreateReminder(
            recurringTransactionId: _selectedTransaction!.id,
            dueDate: _dueDate,
            daysBeforeDue: _daysBeforeDue,
          ),
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminder created')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Reminder'),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : _recurringTransactions.isEmpty
              ? const SizedBox(
                  height: 100,
                  child: Center(
                    child: Text(
                      'No recurring transactions found.\nCreate a recurring transaction first.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<RecurringTransaction>(
                          initialValue: _selectedTransaction,
                          decoration: const InputDecoration(
                            labelText: 'Recurring Transaction',
                            hintText: 'Select a transaction',
                          ),
                          items: _recurringTransactions.map((t) {
                            return DropdownMenuItem(
                              value: t,
                              child: Text(
                                '${t.description} (\$${t.amount.toStringAsFixed(2)})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedTransaction = val);
                            }
                          },
                          validator: (val) =>
                              val == null ? 'Select a transaction' : null,
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Due Date',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              DateFormat.yMMMd().format(_dueDate),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: _daysBeforeDue.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Days Before Due',
                            hintText: '3',
                            suffixText: 'days',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Enter days before due';
                            }
                            final n = int.tryParse(val);
                            if (n == null || n < 0) {
                              return 'Must be 0 or more';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            final n = int.tryParse(val);
                            if (n != null && n >= 0) {
                              _daysBeforeDue = n;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (_recurringTransactions.isNotEmpty)
          FilledButton(
            onPressed: _onCreate,
            child: const Text('Create'),
          ),
      ],
    );
  }
}
