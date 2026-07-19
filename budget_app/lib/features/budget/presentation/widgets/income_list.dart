import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/shared/widgets/empty_state_widget.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';

import 'category_grouped_list.dart';
import 'filter_models.dart';

class IncomeList extends StatelessWidget {
  final List<IncomeEntry> entries;
  final Function(IncomeEntry) onEdit;
  final Function(IncomeEntry) onDelete;
  final Function(IncomeEntry)? onConfirm;
  final SortField sortField;
  final SortOrder sortOrder;
  final GroupMode groupMode;

  const IncomeList({
    super.key,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
    this.onConfirm,
    this.sortField = SortField.date,
    this.sortOrder = SortOrder.descending,
    this.groupMode = GroupMode.category,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const EmptyStateWidget(
        message: 'No income entries yet.\nAdd your first income!',
        icon: Icons.attach_money,
      );
    }

    final currencyCode = context
        .watch<SettingsBloc>()
        .state
        .settings
        .currencyCode;

    return CategoryGroupedList(
      entries: entries,
      isExpense: false,
      currencyCode: currencyCode,
      onEdit: (entry) => onEdit(entry as IncomeEntry),
      onDelete: (entry) => onDelete(entry as IncomeEntry),
      onConfirm: onConfirm != null
          ? (entry) => onConfirm!(entry as IncomeEntry)
          : null,
      sortField: sortField,
      sortOrder: sortOrder,
      groupMode: groupMode,
    );
  }
}
