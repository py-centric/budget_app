import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/math_expression_parser.dart';
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/recurring_transaction.dart';
import 'split_transaction_dialog.dart';

class ExpenseForm extends StatefulWidget {
  final List<Category> categories;
  final Function(
    String id,
    double amount,
    String categoryId,
    String? description,
    DateTime date, {
    bool isRecurring,
    int? interval,
    RecurrenceUnit? unit,
    DateTime? endDate,
    bool isPotential,
    List<SplitItem>? splits,
  })
  onSubmit;

  const ExpenseForm({
    super.key,
    required this.onSubmit,
    required this.categories,
  });

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _intervalController = TextEditingController(text: '1');
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  bool _isPotential = false;
  RecurrenceUnit _selectedUnit = RecurrenceUnit.months;
  DateTime? _endDate;
  List<SplitItem>? _splits;
  bool _isSplit = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = MathExpressionParser.evaluate(_amountController.text);
      if (amount != null && amount > 0) {
        if (_isSplit && _splits != null && _splits!.isNotEmpty) {
          widget.onSubmit(
            '',
            amount,
            _selectedCategoryId ?? widget.categories.first.id,
            _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            _selectedDate,
            isRecurring: _isRecurring,
            interval: _isRecurring
                ? int.tryParse(_intervalController.text)
                : null,
            unit: _isRecurring ? _selectedUnit : null,
            endDate: _isRecurring ? _endDate : null,
            isPotential: _isPotential,
            splits: _splits,
          );
        } else if (_selectedCategoryId != null) {
          widget.onSubmit(
            '',
            amount,
            _selectedCategoryId!,
            _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            _selectedDate,
            isRecurring: _isRecurring,
            interval: _isRecurring
                ? int.tryParse(_intervalController.text)
                : null,
            unit: _isRecurring ? _selectedUnit : null,
            endDate: _isRecurring ? _endDate : null,
            isPotential: _isPotential,
          );
        }
        _amountController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedDate = DateTime.now();
          _isRecurring = false;
          _isPotential = false;
          _endDate = null;
          _intervalController.text = '1';
          _isSplit = false;
          _splits = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added successfully!')),
        );
      }
    }
  }

  void _showSplitDialog() {
    final amount = MathExpressionParser.evaluate(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount first')),
      );
      return;
    }

    final expenseCategories = widget.categories
        .where((c) => c.type == CategoryType.expense)
        .toList();

    if (expenseCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No expense categories available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => SplitTransactionDialog(
        categories: expenseCategories,
        totalAmount: amount,
        existingSplits: _splits,
        isExpense: true,
        onSave: (splits) {
          setState(() {
            _splits = splits;
            _isSplit = splits.isNotEmpty;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add Expense',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, settingsState) {
                    final currencyCode = settingsState.settings.currencyCode;
                    return MathTextField(
                      controller: _amountController,
                      labelText: 'Amount',
                      prefixText:
                          '${CurrencyFormatter.getSymbol(currencyCode: currencyCode)} ',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        final amount = MathExpressionParser.evaluate(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid positive amount or expression';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: widget.categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  validator: (value) {
                    if ((value == null || value.isEmpty) && !_isSplit) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                if (!_isSplit)
                  OutlinedButton.icon(
                    onPressed: () => _showSplitDialog(),
                    icon: const Icon(Icons.call_split, size: 18),
                    label: const Text('Split Transaction'),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Split into ${_splits?.length ?? 0} categories',
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSplit = false;
                              _splits = null;
                            });
                          },
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  maxLength: 200,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Potential Expense (Not Guaranteed)'),
                  value: _isPotential,
                  onChanged: (value) {
                    setState(() {
                      _isPotential = value;
                    });
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Recurring Transaction'),
                  value: _isRecurring,
                  onChanged: (value) {
                    setState(() {
                      _isRecurring = value;
                    });
                  },
                ),
                if (_isRecurring) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _intervalController,
                          decoration: const InputDecoration(labelText: 'Every'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (_isRecurring &&
                                (value == null || value.isEmpty)) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<RecurrenceUnit>(
                          initialValue: _selectedUnit,
                          decoration: const InputDecoration(labelText: 'Unit'),
                          items: RecurrenceUnit.values.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(
                                unit.toString().split('.').last.toUpperCase(),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedUnit = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_note),
                    title: Text(
                      _endDate == null
                          ? 'Ends: Never'
                          : 'Ends: ${_endDate!.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: _endDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _endDate = null),
                          )
                        : null,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            _endDate ??
                            _selectedDate.add(const Duration(days: 30)),
                        firstDate: _selectedDate,
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _endDate = picked;
                        });
                      }
                    },
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.remove),
                  label: const Text('Add Expense'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
