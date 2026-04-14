import 'package:flutter/material.dart';
import '../../domain/entities/income_entry.dart';
import '../../domain/entities/expense_entry.dart';
import 'filter_models.dart';
import 'filter_utils.dart';
import 'search_field.dart';
import 'amount_filter_control.dart';

class FilterBar extends StatefulWidget {
  final List<IncomeEntry> incomeEntries;
  final List<ExpenseEntry> expenseEntries;
  final Function(IncomeEntry) onEditIncome;
  final Function(IncomeEntry) onDeleteIncome;
  final Function(IncomeEntry)? onConfirmIncome;
  final Function(ExpenseEntry) onEditExpense;
  final Function(ExpenseEntry) onDeleteExpense;
  final Function(ExpenseEntry)? onConfirmExpense;
  final Widget Function(
    List<IncomeEntry>,
    Function(IncomeEntry),
    Function(IncomeEntry),
    Function(IncomeEntry)?,
  )
  incomeListBuilder;
  final Widget Function(
    List<ExpenseEntry>,
    Function(ExpenseEntry),
    Function(ExpenseEntry),
    Function(ExpenseEntry)?,
  )
  expenseListBuilder;

  const FilterBar({
    super.key,
    required this.incomeEntries,
    required this.expenseEntries,
    required this.onEditIncome,
    required this.onDeleteIncome,
    this.onConfirmIncome,
    required this.onEditExpense,
    required this.onDeleteExpense,
    this.onConfirmExpense,
    required this.incomeListBuilder,
    required this.expenseListBuilder,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  FilterState _filterState = const FilterState();

  void _updateSearchQuery(String query) {
    setState(() {
      _filterState = _filterState.copyWith(
        searchQuery: query,
        clearSearchQuery: query.isEmpty,
      );
    });
  }

  void _clearSearch() {
    setState(() {
      _filterState = _filterState.copyWith(clearSearchQuery: true);
    });
  }

  void _updateAmountFilter(AmountFilter? filter) {
    setState(() {
      _filterState = _filterState.copyWith(
        amountFilter: filter,
        clearAmountFilter: filter == null,
      );
    });
  }

  void _clearAmountFilter() {
    setState(() {
      _filterState = _filterState.copyWith(clearAmountFilter: true);
    });
  }

  void _updateScope(FilterScope? scope) {
    if (scope != null) {
      setState(() {
        _filterState = _filterState.copyWith(scope: scope);
      });
    }
  }

  void _clearAll() {
    setState(() {
      _filterState = _filterState.clearAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredIncome = filterIncomeEntries(
      widget.incomeEntries,
      _filterState,
    );
    final filteredExpenses = filterExpenseEntries(
      widget.expenseEntries,
      _filterState,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SearchField(
                        initialValue: _filterState.searchQuery,
                        onChanged: _updateSearchQuery,
                        onClear: _clearSearch,
                      ),
                    ),
                    if (_filterState.hasActiveFilters) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: _clearAll,
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('Clear'),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                AmountFilterControl(
                  initialValue: _filterState.amountFilter,
                  onChanged: _updateAmountFilter,
                  onClear: _clearAmountFilter,
                ),
                const SizedBox(height: 12),
                SegmentedButton<FilterScope>(
                  segments: FilterScope.values.map((scope) {
                    return ButtonSegment(
                      value: scope,
                      label: Text(scope.label),
                      icon: Icon(_getScopeIcon(scope)),
                    );
                  }).toList(),
                  selected: {_filterState.scope},
                  onSelectionChanged: (selection) {
                    _updateScope(selection.first);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_filterState.scope == FilterScope.incomeOnly ||
            _filterState.scope == FilterScope.both) ...[
          _buildIncomeSection(filteredIncome),
        ],
        if (_filterState.scope == FilterScope.expenseOnly ||
            _filterState.scope == FilterScope.both) ...[
          _buildExpenseSection(filteredExpenses),
        ],
      ],
    );
  }

  IconData _getScopeIcon(FilterScope scope) {
    switch (scope) {
      case FilterScope.incomeOnly:
        return Icons.arrow_downward;
      case FilterScope.expenseOnly:
        return Icons.arrow_upward;
      case FilterScope.both:
        return Icons.swap_vert;
    }
  }

  Widget _buildIncomeSection(List<IncomeEntry> filtered) {
    final showEmptyState =
        _filterState.hasActiveFilters &&
        filtered.isEmpty &&
        widget.incomeEntries.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterListHeader(
          title: 'Income',
          count: filtered.length,
          total: filtered.fold<double>(0, (sum, e) => sum + e.amount),
          isFiltered: _filterState.hasActiveFilters,
          totalCount: widget.incomeEntries.length,
        ),
        if (showEmptyState)
          _buildEmptyState('No income matches your filters')
        else
          widget.incomeListBuilder(
            filtered,
            widget.onEditIncome,
            widget.onDeleteIncome,
            widget.onConfirmIncome,
          ),
      ],
    );
  }

  Widget _buildExpenseSection(List<ExpenseEntry> filtered) {
    final showEmptyState =
        _filterState.hasActiveFilters &&
        filtered.isEmpty &&
        widget.expenseEntries.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterListHeader(
          title: 'Expenses',
          count: filtered.length,
          total: filtered.fold<double>(0, (sum, e) => sum + e.amount),
          isFiltered: _filterState.hasActiveFilters,
          totalCount: widget.expenseEntries.length,
        ),
        if (showEmptyState)
          _buildEmptyState('No expenses match your filters')
        else
          widget.expenseListBuilder(
            filtered,
            widget.onEditExpense,
            widget.onDeleteExpense,
            widget.onConfirmExpense,
          ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: _clearAll, child: const Text('Clear Filters')),
        ],
      ),
    );
  }
}

class FilterListHeader extends StatelessWidget {
  final String title;
  final int count;
  final double total;
  final bool isFiltered;
  final int totalCount;

  const FilterListHeader({
    super.key,
    required this.title,
    required this.count,
    required this.total,
    this.isFiltered = false,
    this.totalCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isFiltered ? '$title ($count of $totalCount)' : title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
