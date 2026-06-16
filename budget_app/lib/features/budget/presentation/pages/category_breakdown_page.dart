import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:budget_app/core/utils/currency_formatter.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:budget_app/features/budget/domain/entities/income_entry.dart';
import 'package:budget_app/features/budget/domain/entities/expense_entry.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/presentation/bloc/navigation_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_event.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_state.dart';

class CategoryBreakdownPage extends StatefulWidget {
  const CategoryBreakdownPage({super.key});

  @override
  State<CategoryBreakdownPage> createState() => _CategoryBreakdownPageState();
}

class _CategoryBreakdownPageState extends State<CategoryBreakdownPage> {
  final Set<String> _collapsedIncomeCategories = {};
  final Set<String> _collapsedExpenseCategories = {};
  BudgetPeriod _currentPeriod = BudgetPeriod.current();

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
      _currentPeriod = navState.currentPeriod;
    });
    context.read<BudgetBloc>().add(
      LoadSummaryEvent(
        period: _currentPeriod,
        budgetId: navState.activeBudget?.id,
      ),
    );
  }

  void _previousPeriod() {
    setState(() {
      _currentPeriod = _currentPeriod.previous;
      _collapsedIncomeCategories.clear();
      _collapsedExpenseCategories.clear();
    });
    final navState = context.read<NavigationBloc>().state;
    context.read<BudgetBloc>().add(
      LoadSummaryEvent(
        period: _currentPeriod,
        budgetId: navState.activeBudget?.id,
      ),
    );
  }

  void _nextPeriod() {
    setState(() {
      _currentPeriod = _currentPeriod.next;
      _collapsedIncomeCategories.clear();
      _collapsedExpenseCategories.clear();
    });
    final navState = context.read<NavigationBloc>().state;
    context.read<BudgetBloc>().add(
      LoadSummaryEvent(
        period: _currentPeriod,
        budgetId: navState.activeBudget?.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Breakdown'),
      ),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        buildWhen: (previous, current) =>
            current is SummaryLoaded ||
            current is BudgetLoading ||
            current is BudgetError,
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BudgetError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final summary =
              state is SummaryLoaded ? state.summary : null;

          return _buildContent(context, summary);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic summary) {
    final currencyCode = context
        .watch<SettingsBloc>()
        .state
        .settings
        .currencyCode;

    if (summary == null) {
      return const Center(child: Text('No data available'));
    }

    final incomeEntries = summary.incomeEntries as List<IncomeEntry>;
    final expenseEntries = summary.expenseEntries as List<ExpenseEntry>;

    final totalIncome = summary.totalIncome as double;
    final totalExpenses = summary.totalExpenses as double;
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPeriodSelector(context),
          const SizedBox(height: 16),
          _buildNetSummaryCard(context, net, totalIncome, totalExpenses, currencyCode),
          const SizedBox(height: 24),
          if (incomeByCategory.isNotEmpty) ...[
            Text(
              'INCOME BY CATEGORY',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 24),
          ],
          if (expenseByCategory.isNotEmpty) ...[
            Text(
              'EXPENSES BY CATEGORY',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
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
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No entries found for this period.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    final dateFormat = DateFormat('MMMM yyyy');
    final startDate = _currentPeriod.startDate;
    final endDate = _currentPeriod.endDate;
    final rangeFormat = DateFormat('MMM d, yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousPeriod,
                ),
                Text(
                  dateFormat.format(startDate),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextPeriod,
                ),
              ],
            ),
            Text(
              '${rangeFormat.format(startDate)} - ${rangeFormat.format(endDate)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    final netColor = net >= 0 ? Colors.green : Colors.red;

    return Card(
      color: netColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Net: ${CurrencyFormatter.format(net, currencyCode: currencyCode)}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: netColor,
              ),
            ),
            const SizedBox(height: 8),
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
      margin: const EdgeInsets.only(bottom: 8),
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: groupColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isExpense ? Icons.money_off : Icons.attach_money,
                      size: 18,
                      color: groupColor,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                  const SizedBox(width: 4),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
