import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/emergency_fund/presentation/bloc/emergency_fund_bloc.dart';
import 'package:budget_app/features/emergency_fund/presentation/bloc/emergency_fund_event.dart';

class InsuranceSection extends StatefulWidget {
  const InsuranceSection({super.key});

  @override
  State<InsuranceSection> createState() => _InsuranceSectionState();
}

class _InsuranceSectionState extends State<InsuranceSection> {
  String _selectedType = 'Car';
  final List<String> _types = ['Car', 'Home', 'Health', 'Life', 'Pet', 'Other'];
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Insurance Excess',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    items: _types.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Excess Amount',
                      prefixText: '\$',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text) ?? 0.0;
                if (amount >= 0) {
                  final name = _selectedType + ' Insurance Excess';
                  context.read<EmergencyFundBloc>().add(
                        AddCustomExpense(
                          name,
                          amount,
                        ),
                      );
                  _amountController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
              child: const Text('Add Excess'),
            ),
          ],
        ),
      ),
    );
  }
}
