import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/core/utils/currency_formatter.dart';
import 'package:budget_app/shared/widgets/empty_state_widget.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';

import 'slidable_transaction_item.dart';

class IncomeList extends StatelessWidget {
  final List<IncomeEntry> entries;
  final Function(IncomeEntry) onEdit;
  final Function(IncomeEntry) onDelete;
  final Function(IncomeEntry)? onConfirm;

  const IncomeList({
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
        message: 'No income entries yet.\nAdd your first income!',
        icon: Icons.attach_money,
      );
    }

    final currencyCode = context.watch<SettingsBloc>().state.settings.currencyCode;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return SlidableTransactionItem(
          key: ValueKey(entry.id),
          onEdit: () => onEdit(entry),
          onDelete: () => onDelete(entry),
          onConfirm: entry.isPotential ? () => onConfirm?.call(entry) : null,
          child: Opacity(
            opacity: entry.isPotential ? 0.7 : 1.0,
            child: Card(
              shape: entry.isPotential
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.green.shade300, width: 1, style: BorderStyle.solid),
                    )
                  : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: entry.isPotential ? Colors.grey.shade200 : Colors.green.shade100,
                  child: Icon(
                    entry.isPotential ? Icons.help_outline : Icons.arrow_downward,
                    color: entry.isPotential ? Colors.grey : Colors.green.shade700,
                  ),
                ),
                title: Row(
                  children: [
                    Text(CurrencyFormatter.format(entry.amount, currencyCode: currencyCode)),
                    if (entry.isPotential)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '(Potential)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (entry.categoryName != null)
                      Text(
                        'Category: ${entry.categoryName}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    Text(entry.description ?? 'No description'),
                  ],
                ),
                trailing: Text(
                  entry.date.toLocal().toString().split(' ')[0],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
