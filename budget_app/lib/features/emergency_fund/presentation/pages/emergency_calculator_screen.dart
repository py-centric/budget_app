import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/emergency_fund/presentation/bloc/emergency_fund_bloc.dart';
import 'package:budget_app/features/emergency_fund/presentation/bloc/emergency_fund_event.dart';
import 'package:budget_app/features/emergency_fund/presentation/bloc/emergency_fund_state.dart';
import 'package:budget_app/features/emergency_fund/presentation/widgets/expense_item_tile.dart';
import 'package:budget_app/features/emergency_fund/presentation/widgets/living_expenses_calculator.dart';
import 'package:budget_app/features/emergency_fund/presentation/widgets/insurance_section.dart';
import 'package:intl/intl.dart';

class EmergencyCalculatorScreen extends StatelessWidget {
  const EmergencyCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Fund Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: 'Suggestions',
            onPressed: () => _showSuggestionsDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<EmergencyFundBloc, EmergencyFundState>(
        builder: (context, state) {
          if (state.status == EmergencyFundStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final currencyFormat = NumberFormat.currency(symbol: '\$');

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Target Emergency Fund',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormat.format(state.totalTarget),
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: LivingExpensesCalculator(),
              ),
              const SliverToBoxAdapter(
                child: InsuranceSection(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Emergency Expense Items',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              if (state.expenses.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No expenses added yet.\nUse the lightbulb icon for suggestions or add a custom one below.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final expense = state.expenses[index];
                    return ExpenseItemTile(
                      expense: expense,
                      onAmountChanged: (amount) {
                        context.read<EmergencyFundBloc>().add(
                              UpdateExpenseAmount(expense.id, amount),
                            );
                      },
                      onDelete: () {
                        context.read<EmergencyFundBloc>().add(
                              DeleteExpense(expense.id),
                            );
                      },
                    );
                  },
                  childCount: state.expenses.length,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddCustomDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Custom Item'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSuggestionsDialog(BuildContext context) {
    final suggestions = [
      {'name': 'Car Tyres Replacement', 'icon': Icons.directions_car},
      {'name': 'Emergency Home Repairs', 'icon': Icons.home_repair_service},
      {'name': 'Medical Deductibles', 'icon': Icons.medical_services},
      {'name': 'Pet Emergency', 'icon': Icons.pets},
      {'name': 'Unplanned Travel', 'icon': Icons.flight_takeoff},
      {'name': 'Appliance Replacement', 'icon': Icons.kitchen},
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Suggested Items'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return ListTile(
                leading: Icon(suggestion['icon'] as IconData),
                title: Text(suggestion['name'] as String),
                onTap: () {
                  context.read<EmergencyFundBloc>().add(
                        AddCustomExpense(suggestion['name'] as String, 0.0),
                      );
                  Navigator.pop(dialogContext);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddCustomDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Custom Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., Boiler Service',
              ),
              autofocus: true,
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (name.isNotEmpty && amount >= 0) {
                context.read<EmergencyFundBloc>().add(AddCustomExpense(name, amount));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
