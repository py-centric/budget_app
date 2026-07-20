import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:budget_app/features/budget/domain/entities/recurring_transaction.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_event.dart';
import '../../data/recurring_template_presets.dart';
import '../../domain/entities/recurring_template.dart';

class RecurringTemplatesPage extends StatelessWidget {
  const RecurringTemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final presets = RecurringTemplatePresets.presets;
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Add Templates')),
      body: ListView.builder(
        itemCount: presets.length,
        itemBuilder: (context, index) {
          final template = presets[index];
          return ListTile(
            leading: CircleAvatar(
              child: Icon(
                template.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
              ),
            ),
            title: Text(template.name),
            subtitle: Text(template.description),
            trailing: Text(
              '\$${template.defaultAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () => _showQuickAddDialog(context, template),
          );
        },
      ),
    );
  }

  void _showQuickAddDialog(BuildContext context, RecurringTemplate template) {
    final amountController = TextEditingController(text: template.defaultAmount.toString());
    final descController = TextEditingController(text: template.name);
    final intervalController = TextEditingController(text: template.defaultInterval.toString());
    DateTime startDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add ${template.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: intervalController,
                decoration: const InputDecoration(labelText: 'Repeat every'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              ListTile(
                dense: true,
                title: const Text('Start Date'),
                subtitle: Text('${startDate.month}/${startDate.day}/${startDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => startDate = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) return;
                final interval = int.tryParse(intervalController.text) ?? 1;
                final recurring = RecurringTransaction(
                  id: const Uuid().v4(),
                  budgetId: 'default',
                  type: template.type,
                  amount: amount,
                  categoryId: template.defaultCategoryId,
                  description: descController.text,
                  startDate: startDate,
                  interval: interval,
                  unit: RecurrenceUnit.months,
                );
                context.read<BudgetBloc>().add(SaveRecurringTransactionEvent(recurring));
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
