import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';

class DisposableHistoryPage extends StatefulWidget {
  const DisposableHistoryPage({super.key});

  @override
  State<DisposableHistoryPage> createState() => _DisposableHistoryPageState();
}

class _DisposableHistoryPageState extends State<DisposableHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<BudgetBloc>().add(const LoadDisposableHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disposable Budget History')),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DisposableBudgetsLoaded) {
            final history = state.history;
            if (history.isEmpty) {
              return const Center(
                child: Text('No disposed or persisted budgets yet.'),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<BudgetBloc>().add(const LoadDisposableHistoryEvent());
              },
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final budget = history[index];
                  return _buildHistoryItem(budget);
                },
              ),
            );
          }

          if (state is BudgetError) {
            return Center(child: Text(state.message));
          }

          return const Center(child: Text('Loading...'));
        },
      ),
    );
  }

  Widget _buildHistoryItem(Budget budget) {
    final theme = Theme.of(context);
    final isDisposed = budget.type == BudgetType.disposed;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDisposed
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.primaryContainer,
          child: Icon(
            isDisposed ? Icons.archive : Icons.save,
            color: isDisposed
                ? theme.colorScheme.outline
                : theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(budget.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isDisposed ? 'Disposed' : 'Persisted',
              style: TextStyle(
                color: isDisposed
                    ? theme.colorScheme.outline
                    : theme.colorScheme.primary,
                fontSize: 12,
              ),
            ),
            if (budget.targetIncome != null)
              Text(
                'Target: \$${budget.targetIncome!.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12),
              ),
            if (budget.sourceDescription != null && budget.sourceDescription!.isNotEmpty)
              Text(
                budget.sourceDescription!,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              '${_monthName(budget.periodMonth)} ${budget.periodYear}',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: navigate to budget detail showing transactions
        },
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return names[month - 1];
  }
}
