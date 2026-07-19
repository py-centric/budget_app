import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';

class CreateDisposableDialog extends StatefulWidget {
  const CreateDisposableDialog({super.key});

  @override
  State<CreateDisposableDialog> createState() => _CreateDisposableDialogState();
}

class _CreateDisposableDialogState extends State<CreateDisposableDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetIncomeController = TextEditingController();
  final _sourceController = TextEditingController();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _linkIncome = false;
  String? _selectedIncomeId;

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Disposable Budget';
    context.read<BudgetBloc>().add(const LoadIncomeListEvent());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetIncomeController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _onCreate() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final targetIncome = double.parse(_targetIncomeController.text);
    final source = _sourceController.text.trim();

    context.read<BudgetBloc>().add(
      CreateDisposableBudgetEvent(
        name: name,
        targetIncome: targetIncome,
        sourceDescription: source,
        periodMonth: _selectedMonth,
        periodYear: _selectedYear,
        linkedIncomeId: _linkIncome ? _selectedIncomeId : null,
      ),
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Disposable budget "$name" created')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Disposable Budget'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Budget Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a budget name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetIncomeController,
                decoration: const InputDecoration(
                  labelText: 'Target Income Amount',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter target income';
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Must be a positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sourceController,
                decoration: const InputDecoration(
                  labelText: 'Source Description',
                  hintText: 'e.g., Freelance payment for equipment',
                ),
                maxLength: 200,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a source description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedMonth,
                      decoration: const InputDecoration(labelText: 'Month'),
                      items: List.generate(12, (i) {
                        return DropdownMenuItem<int>(
                          value: i + 1,
                          child: Text(_monthNames[i]),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedMonth = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _selectedYear.toString(),
                      decoration: const InputDecoration(labelText: 'Year'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        final year = int.tryParse(val);
                        if (year != null) _selectedYear = year;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter a year';
                        final year = int.tryParse(value);
                        if (year == null || year <= 2000 || year > 2100) {
                          return 'Year must be between 2001 and 2100';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _linkIncome,
                onChanged: (val) {
                  setState(() => _linkIncome = val ?? false);
                },
                title: const Text('Link to existing income'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              if (_linkIncome)
                BlocBuilder<BudgetBloc, BudgetState>(
                  builder: (context, state) {
                    if (state is IncomeListLoaded) {
                      if (state.incomes.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('No income entries available to link.'),
                        );
                      }
                      return DropdownButtonFormField<String>(
                        value: _selectedIncomeId,
                        decoration: const InputDecoration(labelText: 'Select Income'),
                        items: state.incomes.map((income) {
                          return DropdownMenuItem<String>(
                            value: income.id,
                            child: Text(
                              '\$${income.amount.toStringAsFixed(2)} ${income.description ?? ''}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedIncomeId = val);
                        },
                        validator: (value) {
                          if (_linkIncome && (value == null || value.isEmpty)) {
                            return 'Select an income entry';
                          }
                          return null;
                        },
                      );
                    }
                    return const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Loading income entries...'),
                    );
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
        ElevatedButton(
          onPressed: _onCreate,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
