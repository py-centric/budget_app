import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/math_expression_parser.dart';
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/accounts/domain/entities/account.dart';
import '../../../../features/accounts/presentation/bloc/account_bloc.dart';
import '../../../../features/accounts/presentation/bloc/account_state.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_period.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/income_entry.dart';
import '../../domain/entities/expense_entry.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../bloc/navigation_bloc.dart';
import 'category_dropdown.dart';
import 'split_transaction_dialog.dart';

class TransactionForm extends StatefulWidget {
  final bool isIncome;
  final List<Category> categories;
  final List<Account>? accounts;
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
    String? targetBudgetId,
    String? accountId,
  })
  onSubmit;
  final dynamic existingEntry;
  final int periodYear;
  final int periodMonth;

  const TransactionForm({
    super.key,
    required this.isIncome,
    required this.categories,
    this.accounts,
    required this.onSubmit,
    this.existingEntry,
    required this.periodYear,
    required this.periodMonth,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _intervalController = TextEditingController(text: '1');
  String? _selectedCategoryId;
  String? _selectedAccountId;
  late DateTime _selectedDate;
  bool _isRecurring = false;
  bool _isPotential = false;
  RecurrenceUnit _selectedUnit = RecurrenceUnit.months;
  DateTime? _endDate;
  List<SplitItem>? _splits;
  bool _isSplit = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(widget.periodYear, widget.periodMonth, 1);
    if (widget.existingEntry != null) {
      if (widget.existingEntry is IncomeEntry) {
        final entry = widget.existingEntry as IncomeEntry;
        _selectedAccountId = entry.accountId;
        _selectedCategoryId = entry.categoryId;
        _amountController.text = entry.amount.toString();
        _descriptionController.text = entry.description ?? '';
        _selectedDate = entry.date;
        _isPotential = entry.isPotential;
      } else if (widget.existingEntry is ExpenseEntry) {
        final entry = widget.existingEntry as ExpenseEntry;
        _selectedAccountId = entry.accountId;
        _selectedCategoryId = entry.categoryId;
        _amountController.text = entry.amount.toString();
        _descriptionController.text = entry.description ?? '';
        _selectedDate = entry.date;
        _isPotential = entry.isPotential;
      }
    } else {
      final matching = widget.categories
          .where((c) => c.type == _categoryType)
          .toList();
      if (matching.isNotEmpty) {
        _selectedCategoryId = matching.first.id;
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  String get _title => widget.isIncome ? 'Add Income' : 'Add Expense';

  String get _potentialLabel => widget.isIncome
      ? 'Potential Income (Not Guaranteed)'
      : 'Potential Expense (Not Guaranteed)';

  IconData get _submitIcon => widget.isIncome ? Icons.add : Icons.remove;

  String get _submitLabel => widget.isIncome ? 'Add Income' : 'Add Expense';

  String get _successMessage => widget.isIncome
      ? 'Income added successfully!'
      : 'Expense added successfully!';

  CategoryType get _categoryType =>
      widget.isIncome ? CategoryType.income : CategoryType.expense;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final amount = MathExpressionParser.evaluate(_amountController.text);
      if (amount != null && amount > 0) {
        String? targetBudgetId;

        if (_selectedDate.year != widget.periodYear ||
            _selectedDate.month != widget.periodMonth) {
          final choice = await _showDateOutsidePeriodDialog();
          if (choice == _DateChoice.cancel) return;
          if (choice == _DateChoice.move && mounted) {
            final newPeriod = BudgetPeriod.fromDate(_selectedDate);
            final newBudgetId =
                'default_${newPeriod.year}_${newPeriod.month}';
            targetBudgetId = newBudgetId;
            final navBloc = context.read<NavigationBloc>();
            final budgets =
                await navBloc.budgetRepository.getBudgetsForPeriod(
                  newPeriod,
                );
            if (budgets.isEmpty) {
              await navBloc.budgetRepository.addBudget(
                Budget(
                  id: newBudgetId,
                  name: 'Main Budget',
                  periodMonth: newPeriod.month,
                  periodYear: newPeriod.year,
                  isActive: true,
                ),
              );
            }
            navBloc.add(ChangePeriod(newPeriod));
          }
        }

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
            targetBudgetId: targetBudgetId,
            accountId: _selectedAccountId,
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
            targetBudgetId: targetBudgetId,
            accountId: _selectedAccountId,
          );
        }
        if (!mounted) return;
        _amountController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedDate = DateTime(widget.periodYear, widget.periodMonth, 1);
          _selectedAccountId = null;
          _isRecurring = false;
          _isPotential = false;
          _endDate = null;
          _intervalController.text = '1';
          _isSplit = false;
          _splits = null;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_successMessage)));
      }
    }
  }

  Future<_DateChoice> _showDateOutsidePeriodDialog() async {
    final currentMonthName = DateFormat('MMMM').format(
      DateTime(widget.periodYear, widget.periodMonth, 1),
    );
    final entryMonthName = DateFormat('MMMM').format(_selectedDate);
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(
      _selectedDate,
    );
    return await showDialog<_DateChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Date Outside Budget Period'),
        content: Text(
          'This entry is dated $formattedDate. It falls outside the current $currentMonthName ${widget.periodYear} budget. Would you like to move it to the $entryMonthName ${_selectedDate.year} budget instead?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _DateChoice.keep),
            child: Text(
              'Keep in $currentMonthName ${widget.periodYear}',
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _DateChoice.move),
            child: Text(
              'Move to $entryMonthName ${_selectedDate.year}',
            ),
          ),
        ],
      ),
    ).then((v) => v ?? _DateChoice.cancel);
  }

  void _showSplitDialog() {
    final amount = MathExpressionParser.evaluate(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount first')),
      );
      return;
    }

    final filteredCategories = widget.categories
        .where((c) => c.type == _categoryType)
        .toList();

    if (filteredCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isIncome
                ? 'No income categories available'
                : 'No expense categories available',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => SplitTransactionDialog(
        totalAmount: amount,
        categories: filteredCategories,
        existingSplits: _splits,
        onSave: (splits) {
          setState(() {
            _splits = splits;
            _isSplit = splits.isNotEmpty;
            if (_isSplit) {
              _selectedCategoryId = splits.first.categoryId;
            }
          });
        },
      ),
    );
  }

  List<Account> _resolveAccounts(BuildContext context) {
    if (widget.accounts != null) {
      return widget.accounts!;
    }
    try {
      final accountState = context.read<AccountBloc>().state;
      if (accountState is AccountLoaded) {
        return accountState.accounts;
      }
    } catch (_) {}
    return <Account>[];
  }

  @override
  Widget build(BuildContext context) {
    final availableAccounts = _resolveAccounts(context);
    final splitColor = Theme.of(context).colorScheme.tertiary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  final currencyCode = state.settings.currencyCode;
                  final currencySymbol = CurrencyFormatter.getSymbol(
                    currencyCode: currencyCode,
                  );

                  return TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '$currencySymbol ',
                      helperText: 'You can enter math like 10+5*2',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: false,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final parsed = MathExpressionParser.evaluate(value);
                      if (parsed == null || parsed <= 0) {
                        return 'Please enter a valid positive amount or expression';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              CategoryDropdown(
                categories: widget.categories,
                filterType: _categoryType,
                initialValue: _selectedCategoryId,
                labelText: 'Category',
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
                  onPressed: _showSplitDialog,
                  icon: const Icon(Icons.call_split, size: 18),
                  label: const Text('Split Transaction'),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: splitColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: splitColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: splitColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Split into ${_splits?.length ?? 0} categories',
                          style: TextStyle(color: splitColor),
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
              DropdownButtonFormField<String?>(
                key: const Key('transaction_account_dropdown'),
                initialValue: _selectedAccountId,
                decoration: InputDecoration(
                  labelText: 'Account (optional)',
                  prefixIcon: Icon(
                    Icons.account_balance,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('None (Unassigned)'),
                  ),
                  ...availableAccounts.map(
                    (acc) => DropdownMenuItem<String?>(
                      value: acc.id,
                      child: Row(
                        children: [
                          Text(acc.name),
                          const SizedBox(width: 8),
                          Text(
                            '(${acc.type.displayName})',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedAccountId = value;
                  });
                },
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
                title: Text(_potentialLabel),
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
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_busy),
                  title: Text(
                    _endDate == null
                        ? 'No End Date (Never expires)'
                        : 'End Date: ${_endDate!.toLocal().toString().split(' ')[0]}',
                  ),
                  trailing: _endDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _endDate = null;
                            });
                          },
                        )
                      : null,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? _selectedDate,
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
                icon: Icon(_submitIcon),
                label: Text(_submitLabel),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _DateChoice { keep, move, cancel }
