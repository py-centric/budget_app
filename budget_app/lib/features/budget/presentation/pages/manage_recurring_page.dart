import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/recurring_repository.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import 'package:budget_app/shared/widgets/branding_footer.dart';

class ManageRecurringPage extends StatefulWidget {
  const ManageRecurringPage({super.key});

  @override
  State<ManageRecurringPage> createState() => _ManageRecurringPageState();
}

class _ManageRecurringPageState extends State<ManageRecurringPage> {
  String _filter = 'ALL'; // 'ALL', 'INCOME', 'EXPENSE'

  @override
  Widget build(BuildContext context) {
    final recurringRepo = context.read<RecurringRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Transactions'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) => setState(() => _filter = val),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'ALL', child: Text('All')),
              const PopupMenuItem(value: 'INCOME', child: Text('Income')),
              const PopupMenuItem(value: 'EXPENSE', child: Text('Expenses')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: FutureBuilder<List<RecurringTransaction>>(
        future: recurringRepo.getAllRecurringTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          final filteredItems = _filter == 'ALL'
              ? items
              : items.where((i) => i.type == _filter).toList();

          if (filteredItems.isEmpty) {
            return const EmptyStateWidget(
              message: 'No recurring transactions found.',
              icon: Icons.repeat,
            );
          }

          return ListView.builder(
            itemCount: filteredItems.length + 1,
            itemBuilder: (context, index) {
              if (index == filteredItems.length) {
                return const BrandingFooter();
              }
              final item = filteredItems[index];
              return ListTile(
                leading: Icon(
                  item.type == 'INCOME'
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: item.type == 'INCOME'
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
                title: Text(item.description),
                subtitle: Text(
                  'Every ${item.interval} ${item.unit.toString().split('.').last}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(CurrencyFormatter.format(item.amount)),
                    IconButton(
                      icon: Icon(Icons.delete,
                          color: Theme.of(context).colorScheme.error),
                      onPressed: () => _confirmDelete(context, item),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, RecurringTransaction item) {
    final recurringRepo = context.read<RecurringRepository>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recurring Template'),
        content: Text(
          'Are you sure you want to delete "${item.description}"? All future projections will be updated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final budgetBloc = context.read<BudgetBloc>();
              await recurringRepo.deleteRecurringTransaction(item.id);
              if (mounted) {
                navigator.pop();
                setState(() {}); // Refresh list
                budgetBloc.add(const LoadSummaryEvent());
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
