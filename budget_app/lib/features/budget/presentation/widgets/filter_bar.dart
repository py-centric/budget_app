import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/income_entry.dart';
import '../../domain/entities/expense_entry.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import 'filter_models.dart';
import 'filter_utils.dart';
import '../../../../core/utils/currency_formatter.dart';

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

  String get _currencyCode =>
      context.read<SettingsBloc>().state.settings.currencyCode;

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

  void _showSearchSheet(BuildContext context) {
    final controller = TextEditingController(text: _filterState.searchQuery);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Search', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by description...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AmountFilterSheet(
        initialValue: _filterState.amountFilter,
        onChanged: (filter) {
          if (filter == null) {
            _clearAmountFilter();
          } else {
            _updateAmountFilter(filter);
          }
        },
      ),
    );
  }

  @override
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _FilterButton(
                      icon: Icons.search,
                      label: 'Search',
                      isActive: _filterState.searchQuery?.isNotEmpty == true,
                      onPressed: () => _showSearchSheet(context),
                    ),
                    const SizedBox(width: 8),
                    _FilterButton(
                      icon: Icons.filter_list,
                      label: 'Filter',
                      isActive: _filterState.amountFilter != null,
                      onPressed: () => _showFilterSheet(context),
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

class _FilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _FilterButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: isActive,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}

class _AmountFilterSheet extends StatefulWidget {
  final AmountFilter? initialValue;
  final ValueChanged<AmountFilter?> onChanged;

  const _AmountFilterSheet({this.initialValue, required this.onChanged});

  @override
  State<_AmountFilterSheet> createState() => _AmountFilterSheetState();
}

class _AmountFilterSheetState extends State<_AmountFilterSheet> {
  late AmountOperator _selectedOperator;
  late TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _selectedOperator =
        widget.initialValue?.operator ?? AmountOperator.lessThan;
    _valueController = TextEditingController(
      text: widget.initialValue?.value.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _updateFilter() {
    final valueText = _valueController.text.trim();
    if (valueText.isEmpty) {
      widget.onChanged(null);
      return;
    }
    final value = double.tryParse(valueText);
    if (value != null && value >= 0) {
      widget.onChanged(AmountFilter(operator: _selectedOperator, value: value));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Amount Filter',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<AmountOperator>(
                  initialValue: _selectedOperator,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: AmountOperator.values.map((op) {
                    return DropdownMenuItem(
                      value: op,
                      child: Text('${op.symbol} ${op.label}'),
                    );
                  }).toList(),
                  onChanged: (op) {
                    if (op != null) {
                      setState(() => _selectedOperator = op);
                      _updateFilter();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _valueController,
                  decoration: InputDecoration(
                    labelText: 'Value',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  onChanged: (_) => _updateFilter(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.initialValue != null ||
                  _valueController.text.isNotEmpty)
                TextButton(
                  onPressed: () {
                    widget.onChanged(null);
                    Navigator.pop(context);
                  },
                  child: const Text('Clear'),
                ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
  final String? currencyCode;

  const FilterListHeader({
    super.key,
    required this.title,
    required this.count,
    required this.total,
    this.isFiltered = false,
    this.totalCount = 0,
    this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final code =
        currencyCode ??
        context.watch<SettingsBloc>().state.settings.currencyCode;
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
            CurrencyFormatter.format(total, currencyCode: code),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
