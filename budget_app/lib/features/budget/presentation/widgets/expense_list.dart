import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/core/utils/currency_formatter.dart';
import 'package:budget_app/shared/widgets/empty_state_widget.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';

import 'slidable_transaction_item.dart';

class ExpenseList extends StatelessWidget {
  final List<ExpenseEntry> entries;
  final Function(ExpenseEntry) onEdit;
  final Function(ExpenseEntry) onDelete;
  final Function(ExpenseEntry)? onConfirm;

  const ExpenseList({
    super.key,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const EmptyStateWidget(
        message: 'No expense entries yet.\nAdd your first expense!',
        icon: Icons.money_off,
      );
    }

    final currencyCode = context
        .watch<SettingsBloc>()
        .state
        .settings
        .currencyCode;

    return Column(
      children: entries.map((entry) {
        return SlidableTransactionItem(
          key: ValueKey(entry.id),
          onTap: () => onEdit(entry),
          onEdit: () => onEdit(entry),
          onDelete: () => onDelete(entry),
          onConfirm: entry.isPotential ? () => onConfirm?.call(entry) : null,
          child: Opacity(
            opacity: entry.isPotential ? 0.7 : 1.0,
            child: Card(
              shape: entry.isPotential
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    )
                  : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: entry.isPotential
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Theme.of(context).colorScheme.errorContainer,
                  child: Icon(
                    entry.isPotential ? Icons.help_outline : Icons.arrow_upward,
                    color: entry.isPotential
                        ? Theme.of(context).colorScheme.outline
                        : Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      CurrencyFormatter.format(
                        entry.amount,
                        currencyCode: currencyCode,
                      ),
                    ),
                    if (entry.isPotential)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '(Potential)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category: ${entry.categoryName ?? entry.categoryId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (entry.description != null) Text(entry.description!),
                  ],
                ),
                trailing: Text(
                  entry.date.toLocal().toString().split(' ')[0],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                isThreeLine: entry.description != null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
