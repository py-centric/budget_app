import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:budget_app/core/theme/app_spacing.dart';
import 'package:budget_app/core/utils/currency_formatter.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/presentation/bloc/navigation_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_event.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_state.dart';
import 'package:budget_app/features/budget/domain/usecases/calculate_summary.dart';
import 'package:budget_app/shared/widgets/branding_footer.dart';

class CategoryBreakdownPage extends StatefulWidget {
  const CategoryBreakdownPage({super.key});

  @override
  State<CategoryBreakdownPage> createState() => _CategoryBreakdownPageState();
}

class _CategoryBreakdownPageState extends State<CategoryBreakdownPage> {
  final Set<String> _collapsedIncomeCategories = {};
  final Set<String> _collapsedExpenseCategories = {};
  int _selectedDuration = 1;
  BudgetPeriod _rangeEndPeriod = BudgetPeriod.current();
  Set<String> _selectedBudgetIds = {};
  int _loadIndex = 0;
  final List<_LoadItem> _loadQueue = [];
  final Map<String, BudgetSummary> _loadedSummaries = {};
  bool _isLoadingRange = false;
  int _loadGeneration = 0;

  static const List<int> _durations = [1, 3, 6, 12];
  static const List<String> _durationLabels = ['1M', '3M', '6M', '1Y'];

  static const List<Color> _budgetColors = [
    Colors.blue,
    Colors.teal,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.green,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final navState = context.read<NavigationBloc>().state;
    setState(() {
      _rangeEndPeriod = navState.currentPeriod;
      _selectedDuration = 1;
      _selectedBudgetIds = {};
    });
    _startRangeLoad();
  }

  void _previousRange() {
    setState(() {
      int m = _rangeEndPeriod.month - _selectedDuration;
      int y = _rangeEndPeriod.year;
      while (m < 1) {
        m += 12;
        y -= 1;
      }
      _rangeEndPeriod = BudgetPeriod(year: y, month: m);
      _collapsedIncomeCategories.clear();
      _collapsedExpenseCategories.clear();
    });
    _startRangeLoad();
  }

  void _nextRange() {
    setState(() {
      int m = _rangeEndPeriod.month + _selectedDuration;
      int y = _rangeEndPeriod.year;
      while (m > 12) {
        m -= 12;
        y += 1;
      }
      _rangeEndPeriod = BudgetPeriod(year: y, month: m);
      _collapsedIncomeCategories.clear();
      _collapsedExpenseCategories.clear();
    });
    _startRangeLoad();
  }

  void _loadDataForPeriod(BudgetPeriod period) {
    setState(() {
      _rangeEndPeriod = period;
      _collapsedIncomeCategories.clear();
      _collapsedExpenseCategories.clear();
    });
    _startRangeLoad();
  }

  void _startRangeLoad() {
    _loadGeneration++;
    _buildLoadQueue();
    _loadIndex = 0;
    _loadedSummaries.clear();
    if (_loadQueue.isEmpty) {
      _isLoadingRange = false;
      setState(() {});
      return;
    }
    _isLoadingRange = true;
    _dispatchNextLoad();
  }

  void _buildLoadQueue() {
    _loadQueue.clear();
    final endMonth = _rangeEndPeriod.month;
    final endYear = _rangeEndPeriod.year;
    for (int i = 0; i < _selectedDuration; i++) {
      int m = endMonth - i;
      int y = endYear;
      while (m < 1) {
        m += 12;
        y -= 1;
      }
      _loadQueue.add(_LoadItem(
        period: BudgetPeriod(year: y, month: m),
        generation: _loadGeneration,
      ));
    }
  }

  void _dispatchNextLoad() {
    if (_loadIndex >= _loadQueue.length) {
      _isLoadingRange = false;
      final validKeys = _loadQueue
          .map((item) => '${item.period.year}-${item.period.month}')
          .toSet();
      _loadedSummaries.removeWhere((key, _) => !validKeys.contains(key));
      final available = _getAvailableBudgetIds();
      _selectedBudgetIds.retainWhere(available.contains);
      if (_selectedBudgetIds.isEmpty) {
        _selectedBudgetIds.addAll(available);
      }
      setState(() {});
      return;
    }
    context.read<BudgetBloc>().add(
      LoadSummaryEvent(period: _loadQueue[_loadIndex].period),
    );
  }

  BudgetSummary _getMergedSummary() {
    if (_loadedSummaries.isEmpty) {
      return const BudgetSummary(
        totalIncome: 0,
        totalExpenses: 0,
        balance: 0,
        totalPotentialIncome: 0,
        totalPotentialExpenses: 0,
        incomeEntries: [],
        expenseEntries: [],
      );
    }
    if (_loadedSummaries.length == 1) {
      return _loadedSummaries.values.first;
    }
    final allIncome = <IncomeEntry>[];
    final allExpenses = <ExpenseEntry>[];
    double totalIncome = 0;
    double totalExpenses = 0;
    double totalPotentialIncome = 0;
    double totalPotentialExpenses = 0;
    int missedCount = 0;
    for (final summary in _loadedSummaries.values) {
      allIncome.addAll(summary.incomeEntries);
      allExpenses.addAll(summary.expenseEntries);
      totalIncome += summary.totalIncome;
      totalExpenses += summary.totalExpenses;
      totalPotentialIncome += summary.totalPotentialIncome;
      totalPotentialExpenses += summary.totalPotentialExpenses;
      missedCount += summary.missedPotentialCount;
    }
    return BudgetSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      balance: totalIncome - totalExpenses,
      totalPotentialIncome: totalPotentialIncome,
      totalPotentialExpenses: totalPotentialExpenses,
      incomeEntries: allIncome,
      expenseEntries: allExpenses,
      missedPotentialCount: missedCount,
    );
  }

  BudgetSummary _getFilteredSummary() {
    final merged = _getMergedSummary();
    if (_selectedBudgetIds.isEmpty) return merged;

    final filteredIncome = merged.incomeEntries
        .where((e) => _selectedBudgetIds.contains(e.budgetId))
        .toList();
    final filteredExpenses = merged.expenseEntries
        .where((e) => _selectedBudgetIds.contains(e.budgetId))
        .toList();

    double calcTotalIncome = 0;
    double calcTotalExpenses = 0;
    double calcTotalPotentialIncome = 0;
    double calcTotalPotentialExpenses = 0;

    for (final e in filteredIncome) {
      if (!e.isPotential) calcTotalIncome += e.amount;
      calcTotalPotentialIncome += e.amount;
    }
    for (final e in filteredExpenses) {
      if (!e.isPotential) calcTotalExpenses += e.amount;
      calcTotalPotentialExpenses += e.amount;
    }

    return BudgetSummary(
      totalIncome: calcTotalIncome,
      totalExpenses: calcTotalExpenses,
      balance: calcTotalIncome - calcTotalExpenses,
      totalPotentialIncome: calcTotalPotentialIncome,
      totalPotentialExpenses: calcTotalPotentialExpenses,
      incomeEntries: filteredIncome,
      expenseEntries: filteredExpenses,
      missedPotentialCount: merged.missedPotentialCount,
    );
  }

  Set<String> _getAvailableBudgetIds() {
    final ids = <String>{};
    final merged = _getMergedSummary();
    for (final entry in merged.incomeEntries) {
      ids.add(entry.budgetId);
    }
    for (final entry in merged.expenseEntries) {
      ids.add(entry.budgetId);
    }
    return ids;
  }

  Color _budgetColor(String budgetId) {
    return _budgetColors[budgetId.hashCode.abs() % _budgetColors.length];
  }

  String _budgetName(String budgetId) {
    final navState = context.read<NavigationBloc>().state;
    for (final b in navState.availableBudgetsForPeriod) {
      if (b.id == budgetId) return b.name;
    }
    if (budgetId.startsWith('default_')) {
      return 'Main Budget';
    }
    return budgetId.length > 12 ? budgetId.substring(0, 12) : budgetId;
  }

  String _rangeLabel() {
    if (_selectedDuration == 1) {
      return DateFormat('MMMM yyyy').format(
        DateTime(_rangeEndPeriod.year, _rangeEndPeriod.month),
      );
    }
    int firstMonth = _rangeEndPeriod.month - (_selectedDuration - 1);
    int firstYear = _rangeEndPeriod.year;
    while (firstMonth < 1) {
      firstMonth += 12;
      firstYear -= 1;
    }
    final firstDate = DateTime(firstYear, firstMonth);
    final lastDate = DateTime(_rangeEndPeriod.year, _rangeEndPeriod.month);
    if (firstYear == _rangeEndPeriod.year) {
      return '${DateFormat('MMMM').format(firstDate)} - ${DateFormat('MMMM yyyy').format(lastDate)}';
    }
    return '${DateFormat('MMMM yyyy').format(firstDate)} - ${DateFormat('MMMM yyyy').format(lastDate)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Breakdown'),
      ),
      body: BlocListener<NavigationBloc, NavigationState>(
        listenWhen: (previous, current) =>
            previous.currentPeriod != current.currentPeriod,
        listener: (context, state) {
          if (state.currentPeriod != _rangeEndPeriod) {
            _loadDataForPeriod(state.currentPeriod);
          }
        },
        child: BlocListener<BudgetBloc, BudgetState>(
          listenWhen: (previous, current) =>
              current is SummaryLoaded && _isLoadingRange,
          listener: (context, state) {
            if (_isLoadingRange &&
                _loadIndex < _loadQueue.length) {
              final item = _loadQueue[_loadIndex];
              if (item.generation != _loadGeneration) {
                return;
              }
              if (state is SummaryLoaded) {
                _loadedSummaries[
                    '${item.period.year}-${item.period.month}'] = state.summary;
                _loadIndex++;
                _dispatchNextLoad();
              } else if (state is BudgetError) {
                _loadIndex++;
                _dispatchNextLoad();
              }
            }
          },
          child: BlocBuilder<BudgetBloc, BudgetState>(
            buildWhen: (previous, current) =>
                current is SummaryLoaded ||
                current is BudgetLoading ||
                current is BudgetError,
            builder: (context, state) {
              if (state is BudgetLoading && _loadedSummaries.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is BudgetError && _loadedSummaries.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
                      SizedBox(height: AppSpacing.md),
                      Text('Error: ${state.message}'),
                      SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return _buildContent(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final summary = _getFilteredSummary();
    final currencyCode = context
        .watch<SettingsBloc>()
        .state
        .settings
        .currencyCode;

    if (_loadedSummaries.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final incomeEntries = summary.incomeEntries;
    final expenseEntries = summary.expenseEntries;
    final totalIncome = summary.totalIncome;
    final totalExpenses = summary.totalExpenses;
    final net = totalIncome - totalExpenses;

    final incomeByCategory = _groupEntries<IncomeEntry>(
      incomeEntries,
      (e) => e.categoryId ?? '__uncategorized__',
      (e) => e.categoryName ?? 'Uncategorized',
    );

    final expenseByCategory = _groupEntries<ExpenseEntry>(
      expenseEntries,
      (e) => e.categoryId,
      (e) => e.categoryName ?? 'Uncategorized',
    );

    final showComparison = _selectedBudgetIds.length >= 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDurationChipBar(context),
          SizedBox(height: AppSpacing.sm),
          if (_getAvailableBudgetIds().length > 1) ...[
            _buildBudgetChips(context),
            SizedBox(height: AppSpacing.sm),
          ],
          if (_isLoadingRange) ...[
            const LinearProgressIndicator(),
            SizedBox(height: AppSpacing.sm),
          ],
          SizedBox(height: AppSpacing.md),
          if (showComparison)
            _buildComparisonCard(context, currencyCode)
          else
            _buildNetSummaryCard(context, net, totalIncome, totalExpenses, currencyCode),
          SizedBox(height: AppSpacing.lg),
          if (incomeByCategory.isNotEmpty) ...[
            Text(
              'INCOME BY CATEGORY',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            ...incomeByCategory.entries.map((entry) {
              return _buildCategoryGroup(
                context: context,
                categoryId: entry.key,
                categoryName: entry.value.name,
                entries: entry.value.entries,
                total: entry.value.total,
                grandTotal: totalIncome,
                currencyCode: currencyCode,
                isExpense: false,
                collapsedSet: _collapsedIncomeCategories,
                allEntries: incomeEntries,
              );
            }),
            _buildTotalRow(context, 'Total Income', totalIncome, currencyCode,
                Theme.of(context).colorScheme.primary),
            SizedBox(height: AppSpacing.lg),
          ],
          if (expenseByCategory.isNotEmpty) ...[
            Text(
              'EXPENSES BY CATEGORY',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            ...expenseByCategory.entries.map((entry) {
              return _buildCategoryGroup(
                context: context,
                categoryId: entry.key,
                categoryName: entry.value.name,
                entries: entry.value.entries,
                total: entry.value.total,
                grandTotal: totalExpenses,
                currencyCode: currencyCode,
                isExpense: true,
                collapsedSet: _collapsedExpenseCategories,
                allEntries: expenseEntries,
              );
            }),
            _buildTotalRow(context, 'Total Expenses', totalExpenses, currencyCode,
                Theme.of(context).colorScheme.error),
          ],
          if (incomeByCategory.isEmpty && expenseByCategory.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text(
                  _selectedBudgetIds.length < _getAvailableBudgetIds().length
                      ? 'No entries match the selected budgets.'
                      :               'No entries found for this period.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          const BrandingFooter(),
        ],
      ),
    );
  }

  Widget _buildDurationChipBar(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.sm),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousRange,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_durations.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs / 2),
                          child: ChoiceChip(
                            label: Text(_durationLabels[index]),
                            selected: _selectedDuration == _durations[index],
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedDuration = _durations[index];
                                });
                                _startRangeLoad();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextRange,
                ),
              ],
            ),
            Text(
              _rangeLabel(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetChips(BuildContext context) {
    final availableIds = _getAvailableBudgetIds().toList()..sort();
    if (availableIds.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: availableIds.map((id) {
          final selected = _selectedBudgetIds.contains(id);
          final name = _budgetName(id);
          final color = _budgetColor(id);
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              avatar: CircleAvatar(
                backgroundColor: color,
                radius: 6,
              ),
              label: Text(name),
              selected: selected,
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    _selectedBudgetIds.add(id);
                  } else {
                    _selectedBudgetIds.remove(id);
                  }
                  if (_selectedBudgetIds.isEmpty) {
                    _selectedBudgetIds
                        .addAll(_getAvailableBudgetIds());
                  }
                });
              },
              selectedColor: color.withValues(alpha: 0.15),
              checkmarkColor: color,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildComparisonCard(BuildContext context, String currencyCode) {
    final theme = Theme.of(context);
    final summary = _getFilteredSummary();
    final budgets = <String, _BudgetData>{};

    for (final entry in summary.incomeEntries) {
      if (!_selectedBudgetIds.contains(entry.budgetId)) continue;
      budgets.putIfAbsent(entry.budgetId, _BudgetData.new);
      if (!entry.isPotential) {
        budgets[entry.budgetId]!.actualIncome += entry.amount;
      }
      budgets[entry.budgetId]!.totalIncome += entry.amount;
    }
    for (final entry in summary.expenseEntries) {
      if (!_selectedBudgetIds.contains(entry.budgetId)) continue;
      budgets.putIfAbsent(entry.budgetId, _BudgetData.new);
      if (!entry.isPotential) {
        budgets[entry.budgetId]!.actualExpenses += entry.amount;
      }
      budgets[entry.budgetId]!.totalExpenses += entry.amount;
    }

    final budgetIds = budgets.keys.toList();
    if (budgetIds.length < 2) return const SizedBox.shrink();

    final title = _selectedDuration == 1
        ? 'Budget Comparison — ${_rangeLabel()}'
        : 'Combined (${_rangeLabel()})';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.sm + AppSpacing.xs),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                columns: [
                  const DataColumn(label: Text('')),
                  ...budgetIds.map((id) => DataColumn(
                    label: Text(
                      _budgetName(id),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )),
                ],
                rows: [
                  DataRow(cells: [
                    const DataCell(Text('Income')),
                    ...budgetIds.map((id) => DataCell(
                      Text(CurrencyFormatter.format(
                        budgets[id]!.actualIncome,
                        currencyCode: currencyCode,
                      )),
                    )),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Expenses')),
                    ...budgetIds.map((id) => DataCell(
                      Text(CurrencyFormatter.format(
                        budgets[id]!.actualExpenses,
                        currencyCode: currencyCode,
                      )),
                    )),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Net',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    ...budgetIds.map((id) {
                      final amt = budgets[id]!.actualIncome -
                          budgets[id]!.actualExpenses;
                      return DataCell(
                        Text(
                          CurrencyFormatter.format(amt, currencyCode: currencyCode),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: amt >= 0 ? theme.colorScheme.primary : theme.colorScheme.error,
                          ),
                        ),
                      );
                    }),
                  ]),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Categories below show combined totals across all selected budgets.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetSummaryCard(
    BuildContext context,
    double net,
    double totalIncome,
    double totalExpenses,
    String currencyCode,
  ) {
    final theme = Theme.of(context);
    final netColor = net >= 0 ? theme.colorScheme.primary : theme.colorScheme.error;

    return Card(
      color: netColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text(
              'Net: ${CurrencyFormatter.format(net, currencyCode: currencyCode)}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: netColor,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNetLabel(
                  context,
                  'Income',
                  totalIncome,
                  currencyCode,
                  theme.colorScheme.primary,
                ),
                _buildNetLabel(
                  context,
                  'Expense',
                  totalExpenses,
                  currencyCode,
                  theme.colorScheme.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetLabel(
    BuildContext context,
    String label,
    double amount,
    String currencyCode,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          CurrencyFormatter.format(amount, currencyCode: currencyCode),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGroup({
    required BuildContext context,
    required String categoryId,
    required String categoryName,
    required List<dynamic> entries,
    required double total,
    required double grandTotal,
    required String currencyCode,
    required bool isExpense,
    required Set<String> collapsedSet,
    required List<dynamic> allEntries,
  }) {
    final theme = Theme.of(context);
    final groupColor = isExpense
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    final isCollapsed = collapsedSet.contains(categoryId);
    final percentage = grandTotal > 0 ? (total / grandTotal * 100).round() : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isCollapsed) {
                  collapsedSet.remove(categoryId);
                } else {
                  collapsedSet.add(categoryId);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: groupColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      isExpense ? Icons.money_off : Icons.attach_money,
                      size: 18,
                      color: groupColor,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm + AppSpacing.xs),
                  Expanded(
                    child: Text(
                      categoryName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${CurrencyFormatter.format(total, currencyCode: currencyCode)}  $percentage%',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: groupColor,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  AnimatedRotation(
                    turns: isCollapsed ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: isCollapsed
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Column(
              children: [
                const Divider(height: 1),
                ...entries.map((entry) {
                  return _buildBreakdownEntry(
                    entry, theme, currencyCode, isExpense);
                }),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownEntry(
    dynamic entry,
    ThemeData theme,
    String currencyCode,
    bool isExpense,
  ) {
    String date;
    String amount;
    String? description;

    if (entry is ExpenseEntry) {
      date = entry.date.toLocal().toString().split(' ')[0];
      amount = CurrencyFormatter.format(
        entry.amount,
        currencyCode: currencyCode,
      );
      description = entry.description;
    } else if (entry is IncomeEntry) {
      date = entry.date.toLocal().toString().split(' ')[0];
      amount = CurrencyFormatter.format(
        entry.amount,
        currencyCode: currencyCode,
      );
      description = entry.description;
    } else {
      return const SizedBox.shrink();
    }

    return ListTile(
      dense: true,
      title: Text(
        '$amount${description != null ? ' - $description' : ''}',
        style: theme.textTheme.bodyMedium,
      ),
      trailing: Text(
        date,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildTotalRow(
    BuildContext context,
    String label,
    double total,
    String currencyCode,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            CurrencyFormatter.format(total, currencyCode: currencyCode),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  _CategoryGroupResult _groupEntries<T>(
    List<T> entries,
    String Function(T) getCategoryId,
    String Function(T) getCategoryName,
  ) {
    final map = <String, _CategoryGroupData>{};

    for (final entry in entries) {
      final catId = getCategoryId(entry);
      final catName = getCategoryName(entry);

      map.putIfAbsent(catId, () => _CategoryGroupData(name: catName));
      map[catId]!.entries.add(entry);

      double amount = 0;
      if (entry is ExpenseEntry) {
        amount = entry.amount;
      } else if (entry is IncomeEntry) {
        amount = entry.amount;
      }
      map[catId]!.total += amount;
    }

    final sortedEntries = map.entries.toList()
      ..sort((a, b) => b.value.total.compareTo(a.value.total));

    return _CategoryGroupResult(entries: sortedEntries);
  }
}

class _CategoryGroupData {
  final String name;
  final List<dynamic> entries = [];
  double total = 0;

  _CategoryGroupData({required this.name});
}

class _CategoryGroupResult {
  final List<MapEntry<String, _CategoryGroupData>> entries;

  _CategoryGroupResult({required this.entries});

  bool get isNotEmpty => entries.isNotEmpty;
  bool get isEmpty => entries.isEmpty;
}

class _LoadItem {
  final BudgetPeriod period;
  final int generation;
  const _LoadItem({required this.period, required this.generation});
}

class _BudgetData {
  double actualIncome = 0;
  double actualExpenses = 0;
  double totalIncome = 0;
  double totalExpenses = 0;
}
