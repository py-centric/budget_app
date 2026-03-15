import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/emergency_fund/presentation/bloc/emergency_fund_bloc.dart';
import 'package:budget_app/features/emergency_fund/presentation/bloc/emergency_fund_event.dart';
import 'package:budget_app/features/emergency_fund/presentation/bloc/emergency_fund_state.dart';
import 'package:intl/intl.dart';

class LivingExpensesCalculator extends StatefulWidget {
  const LivingExpensesCalculator({super.key});

  @override
  State<LivingExpensesCalculator> createState() => _LivingExpensesCalculatorState();
}

class _LivingExpensesCalculatorState extends State<LivingExpensesCalculator> {
  int _selectedMonths = 6;
  bool _isManual = false;
  late TextEditingController _manualController;

  @override
  void initState() {
    super.initState();
    _manualController = TextEditingController();
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmergencyFundBloc, EmergencyFundState>(
      builder: (context, state) {
        final currencyFormat = NumberFormat.currency(symbol: '\$');
        final currentAverage = _isManual 
            ? (double.tryParse(_manualController.text) ?? 0.0) 
            : state.averageMonthlySpending;
        final total = currentAverage * _selectedMonths;

        return Card(
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Living Expenses Calculator',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Switch(
                      value: _isManual,
                      onChanged: (value) {
                        setState(() {
                          _isManual = value;
                          if (!_isManual) {
                            _manualController.clear();
                          }
                        });
                      },
                    ),
                  ],
                ),
                Text(
                  _isManual ? 'Manual Input' : 'Automatic (Last 3 months average)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                if (_isManual)
                  TextField(
                    controller: _manualController,
                    decoration: const InputDecoration(
                      labelText: 'Average Monthly Spending',
                      prefixText: '\$',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      if ((double.tryParse(value) ?? 0.0) >= 0) {
                        setState(() {});
                      }
                    },
                  )
                else
                  Text(
                    'Average: ${currencyFormat.format(state.averageMonthlySpending)} / month',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [1, 3, 6, 12].map((m) {
                    return ChoiceChip(
                      label: Text('$m ${m == 1 ? 'Month' : 'Months'}'),
                      selected: _selectedMonths == m,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedMonths = m;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Calculated Goal:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      currencyFormat.format(total),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<EmergencyFundBloc>().add(
                          AddCustomExpense(
                            'Living Expenses ($_selectedMonths ${_selectedMonths == 1 ? 'Month' : 'Months'})',
                            total,
                            categoryType: 'living_expenses',
                          ),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text('Add/Update Emergency Fund'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
