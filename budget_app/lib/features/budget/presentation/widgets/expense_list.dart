import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/shared/widgets/empty_state_widget.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';

import 'category_grouped_list.dart';
import 'filter_models.dart';

class ExpenseList extends StatelessWidget {
  final List<ExpenseEntry> entries;
  final Function(ExpenseEntry) onEdit;
  final Function(ExpenseEntry) onDelete;
  final Function(ExpenseEntry)? onConfirm;
  final SortField sortField;
  final SortOrder sortOrder;
  final GroupMode groupMode;
  final Set<String>? disposableBudgetIds;

  const ExpenseList({
    super.key,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
    this.onConfirm,
    this.sortField = SortField.date,
    this.sortOrder = SortOrder.descending,
    this.groupMode = GroupMode.category,
    this.disposableBudgetIds,
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

    return CategoryGroupedList(
      entries: entries,
      isExpense: true,
      currencyCode: currencyCode,
      onEdit: (entry) => onEdit(entry as ExpenseEntry),
      onDelete: (entry) => onDelete(entry as ExpenseEntry),
      onConfirm: onConfirm != null
          ? (entry) => onConfirm!(entry as ExpenseEntry)
          : null,
      sortField: sortField,
      sortOrder: sortOrder,
      groupMode: groupMode,
      disposableBudgetIds: disposableBudgetIds,
    );
  }
}
