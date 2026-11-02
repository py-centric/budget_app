import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/income_entry.dart';
import '../../domain/entities/expense_entry.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/bloc/account_bloc.dart';
import '../../../accounts/presentation/bloc/account_state.dart';
import 'account_filter_sheet.dart';
import 'filter_bar_sheets.dart';
import 'filter_models.dart';
import 'filter_utils.dart';
import '../../../../core/widgets/adaptive_segmented_control.dart';

export 'filter_bar_sheets.dart' show FilterListHeader;

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
    List<IncomeEntry>, Function(IncomeEntry), Function(IncomeEntry), Function(IncomeEntry)?,
    SortField, SortOrder, GroupMode,
  ) incomeListBuilder;
  final Widget Function(
    List<ExpenseEntry>, Function(ExpenseEntry), Function(ExpenseEntry), Function(ExpenseEntry)?,
    SortField, SortOrder, GroupMode,
  ) expenseListBuilder;

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

  String get _currencyCode => context.read<SettingsBloc>().state.settings.currencyCode;

  void _updateSearchQuery(String query) => setState(
    () => _filterState = _filterState.copyWith(searchQuery: query, clearSearchQuery: query.isEmpty),
  );

  void _clearSearch() => setState(() => _filterState = _filterState.copyWith(clearSearchQuery: true));

  void _updateAmountFilter(AmountFilter? filter) => setState(
    () => _filterState = _filterState.copyWith(amountFilter: filter, clearAmountFilter: filter == null),
  );

  void _clearAmountFilter() => setState(() => _filterState = _filterState.copyWith(clearAmountFilter: true));

  void _updateScope(FilterScope? scope) {
    if (scope != null) setState(() => _filterState = _filterState.copyWith(scope: scope));
  }

  void _updateEntryStatus(EntryStatus? status) {
    if (status != null) setState(() => _filterState = _filterState.copyWith(entryStatus: status));
  }

  void _clearAll() => setState(() => _filterState = _filterState.clearAll());

  void _showSearchSheet(BuildContext context) {
    final controller = TextEditingController(text: _filterState.searchQuery);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Search', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by description...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onSubmitted: (value) {
                _updateSearchQuery(value);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_filterState.searchQuery?.isNotEmpty == true)
                  TextButton(
                    onPressed: () {
                      _clearSearch();
                      Navigator.pop(context);
                    },
                    child: const Text('Clear'),
                  ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    _updateSearchQuery(controller.text);
                    Navigator.pop(context);
                  },
                  child: const Text('Search'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AmountFilterSheet(
        initialValue: _filterState.amountFilter,
        onChanged: (f) => f == null ? _clearAmountFilter() : _updateAmountFilter(f),
      ),
    );
  }

  void _updateAccountFilter(AccountFilter filter) => setState(
    () => _filterState = _filterState.copyWith(
      accountFilter: filter,
      clearAccountFilter: !filter.isActive,
    ),
  );

  void _showAccountFilterSheet(BuildContext context) {
    List<Account> accounts = [];
    try {
      final accountState = context.read<AccountBloc>().state;
      if (accountState is AccountLoaded) accounts = accountState.accounts;
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AccountFilterSheet(
        accounts: accounts,
        initialFilter: _filterState.accountFilter,
        onApply: _updateAccountFilter,
      ),
    );
  }

  void _showSortGroupSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SortGroupSheet(
        initialSortField: _filterState.sortField,
        initialSortOrder: _filterState.sortOrder,
        initialGroupMode: _filterState.groupMode,
        onChanged: (sortField, sortOrder, groupMode) => setState(
          () => _filterState = _filterState.copyWith(
            sortField: sortField,
            sortOrder: sortOrder,
            groupMode: groupMode,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredIncome = filterIncomeEntries(widget.incomeEntries, _filterState);
    final filteredExpenses = filterExpenseEntries(widget.expenseEntries, _filterState);

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
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterActionChipButton(
                              icon: Icons.search,
                              label: 'Search',
                              isActive: _filterState.searchQuery?.isNotEmpty == true,
                              onPressed: () => _showSearchSheet(context),
                            ),
                            const SizedBox(width: 8),
                            FilterActionChipButton(
                              icon: Icons.sort,
                              label: 'Sort',
                              isActive: _filterState.hasActiveSortGroup,
                              onPressed: () => _showSortGroupSheet(context),
                            ),
                            const SizedBox(width: 8),
                            FilterActionChipButton(
                              icon: Icons.filter_list,
                              label: 'Filter',
                              isActive: _filterState.amountFilter != null,
                              onPressed: () => _showFilterSheet(context),
                            ),
                            const SizedBox(width: 8),
                            FilterActionChipButton(
                              icon: Icons.account_balance,
                              label: 'Account',
                              isActive: _filterState.accountFilter.isActive,
                              onPressed: () => _showAccountFilterSheet(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_filterState.hasActiveFilters || _filterState.hasActiveDisplayOptions) ...[
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
                AdaptiveSegmentedControl<FilterScope>(
                  segments: [
                    for (final scope in FilterScope.values)
                      AdaptiveSegment(
                        value: scope,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getScopeIcon(scope)),
                            const SizedBox(width: 4),
                            Text(scope.label),
                          ],
                        ),
                        semanticsLabel: scope.label,
                      ),
                  ],
                  selected: _filterState.scope,
                  onChanged: (value) => _updateScope(value!),
                ),
                const SizedBox(height: 8),
                AdaptiveSegmentedControl<EntryStatus>(
                  segments: [
                    for (final status in EntryStatus.values)
                      AdaptiveSegment(
                        value: status,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(status.icon, size: 18),
                            const SizedBox(width: 4),
                            Text(status.label),
                          ],
                        ),
                        semanticsLabel: status.label,
                      ),
                  ],
                  selected: _filterState.entryStatus,
                  onChanged: (value) => _updateEntryStatus(value!),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_filterState.scope == FilterScope.incomeOnly || _filterState.scope == FilterScope.both)
          _buildIncomeSection(filteredIncome),
        if (_filterState.scope == FilterScope.expenseOnly || _filterState.scope == FilterScope.both)
          _buildExpenseSection(filteredExpenses),
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
        _filterState.hasActiveFilters && filtered.isEmpty && widget.incomeEntries.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterListHeader(
          title: 'Income',
          count: filtered.length,
          total: filtered.fold<double>(0, (sum, e) => sum + e.amount),
          isFiltered: _filterState.hasActiveFilters,
          totalCount: widget.incomeEntries.length,
          currencyCode: _currencyCode,
        ),
        if (showEmptyState)
          _buildEmptyState('No income matches your filters')
        else
          widget.incomeListBuilder(
            filtered,
            widget.onEditIncome,
            widget.onDeleteIncome,
            widget.onConfirmIncome,
            _filterState.sortField,
            _filterState.sortOrder,
            _filterState.groupMode,
          ),
      ],
    );
  }

  Widget _buildExpenseSection(List<ExpenseEntry> filtered) {
    final showEmptyState =
        _filterState.hasActiveFilters && filtered.isEmpty && widget.expenseEntries.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterListHeader(
          title: 'Expenses',
          count: filtered.length,
          total: filtered.fold<double>(0, (sum, e) => sum + e.amount),
          isFiltered: _filterState.hasActiveFilters,
          totalCount: widget.expenseEntries.length,
          currencyCode: _currencyCode,
        ),
        if (showEmptyState)
          _buildEmptyState('No expenses match your filters')
        else
          widget.expenseListBuilder(
            filtered,
            widget.onEditExpense,
            widget.onDeleteExpense,
            widget.onConfirmExpense,
            _filterState.sortField,
            _filterState.sortOrder,
            _filterState.groupMode,
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
