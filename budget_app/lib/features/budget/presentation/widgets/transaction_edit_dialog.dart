import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/income_entry.dart';
import '../../domain/entities/expense_entry.dart';
import '../../domain/entities/category.dart';
import '../budget_bloc.dart';
import '../budget_event.dart';
import 'delete_confirmation_dialog.dart';

class TransactionEditDialog extends StatefulWidget {
  final IncomeEntry? income;
  final ExpenseEntry? expense;
  final List<Category> categories;

  const TransactionEditDialog({
    super.key,
    this.income,
    this.expense,
    required this.categories,
  }) : assert(income != null || expense != null);

  @override
  State<TransactionEditDialog> createState() => _TransactionEditDialogState();
}

class _TransactionEditDialogState extends State<TransactionEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    if (widget.income != null) {
      _amountController = TextEditingController(text: widget.income!.amount.toString());
      _descriptionController = TextEditingController(text: widget.income!.description ?? '');
      _selectedDate = widget.income!.date;
      _selectedCategoryId = widget.income!.categoryId;
    } else {
      _amountController = TextEditingController(text: widget.expense!.amount.toString());
      _descriptionController = TextEditingController(text: widget.expense!.description ?? '');
      _selectedDate = widget.expense!.date;
      _selectedCategoryId = widget.expense!.categoryId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.income != null;
    final relevantCategories = widget.categories
        .where((c) => c.type == (isIncome ? CategoryType.income : CategoryType.expense))
        .toList();

    return AlertDialog(
      title: Text(isIncome ? 'Edit Income' : 'Edit Expense'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter an amount';
                  if (double.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Category'),                items: relevantCategories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  }
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              ListTile(
                title: Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (deleteContext) => DeleteConfirmationDialog(
                title: isIncome ? 'Delete Income' : 'Delete Expense',
                content: 'Are you sure you want to delete this entry?',
                onConfirm: () {
                  context.read<BudgetBloc>().add(
                        DeleteEntryEvent(
                          isIncome ? widget.income!.id : widget.expense!.id,
                          isIncome ? EntryType.income : EntryType.expense,
                        ),
                      );
                  Navigator.pop(context); // Close edit dialog
                },
              ),
            );
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (isIncome) {
                final updatedIncome = IncomeEntry(
                  id: widget.income!.id,
                  budgetId: widget.income!.budgetId,
                  amount: double.parse(_amountController.text),
                  categoryId: _selectedCategoryId,
                  description: _descriptionController.text,
                  date: _selectedDate,
                );
                context.read<BudgetBloc>().add(UpdateIncomeEvent(updatedIncome));
              } else {
                final updatedExpense = ExpenseEntry(
                  id: widget.expense!.id,
                  budgetId: widget.expense!.budgetId,
                  amount: double.parse(_amountController.text),
                  categoryId: _selectedCategoryId!,
                  description: _descriptionController.text,
                  date: _selectedDate,
                );
                context.read<BudgetBloc>().add(UpdateExpenseEvent(updatedExpense));
              }
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
