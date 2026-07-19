import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/budget.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';

class DisposePersistSheet extends StatelessWidget {
  final Budget budget;
  final double totalExpenses;

  const DisposePersistSheet({
    super.key,
    required this.budget,
    this.totalExpenses = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = budget.targetIncome != null
        ? budget.targetIncome! - totalExpenses
        : 0.0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Manage Budget',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            budget.name,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Target: \$${budget.targetIncome?.toStringAsFixed(2) ?? '0.00'}',
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              Text(
                'Remaining: \$${remaining.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: remaining > 0 ? Colors.green : theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: budget.targetIncome != null && budget.targetIncome! > 0
                ? (totalExpenses / budget.targetIncome!).clamp(0.0, 1.0)
                : 0,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              remaining > 0 ? Colors.green : theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 24),
          if (remaining > 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '\$${remaining.toStringAsFixed(2)} in unspent funds will be lost if disposed.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<BudgetBloc>().add(DisposeBudgetEvent(budget.id));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('"${budget.name}" disposed')),
                    );
                  },
                  icon: const Icon(Icons.archive),
                  label: const Text('Dispose'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    context.read<BudgetBloc>().add(PersistBudgetEvent(budget.id));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('"${budget.name}" converted to regular')),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Persist'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
