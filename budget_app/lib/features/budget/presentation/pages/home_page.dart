import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../budget_bloc.dart';
import '../budget_event.dart';
import '../budget_state.dart';
import '../bloc/navigation_bloc.dart';
import '../widgets/income_form.dart';
import '../widgets/expense_form.dart';
import '../widgets/income_list.dart';
import '../widgets/expense_list.dart';
import '../widgets/summary_card.dart';
import '../widgets/navigation_drawer_widget.dart';
import '../widgets/transaction_edit_dialog.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/home_projection_overview.dart';
import '../widgets/duplication_dialog.dart';
import '../widgets/budget_selector.dart';
import '../widgets/list_header_total.dart';
import '../widgets/currency_conversion_dialog.dart';
import '../bloc/projection_bloc.dart';
import '../bloc/projection_event.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/recurring_transaction.dart';

import '../../domain/usecases/calculate_summary.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Category> _categories = [];
  BudgetSummary? _lastSummary;
  bool _showIncomeForm = true;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetBloc>().add(const LoadCategoriesEvent());
      final navState = context.read<NavigationBloc>().state;
      context.read<BudgetBloc>().add(
        LoadSummaryEvent(
          period: navState.currentPeriod,
          budgetId: navState.activeBudget?.id,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, NavigationState>(
      listener: (context, navState) {
        context.read<BudgetBloc>().add(
          LoadSummaryEvent(
            period: navState.currentPeriod,
            budgetId: navState.activeBudget?.id,
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<NavigationBloc, NavigationState>(
            builder: (context, state) {
              if (state.activeBudget != null) {
                return BudgetSelector(
                  budgets: state.availableBudgetsForPeriod,
                  activeBudget: state.activeBudget!,
                );
              }
              return const Text('Budget App');
            },
          ),
          actions: [
            BlocBuilder<NavigationBloc, NavigationState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Duplicate Budget',
                  onPressed: () {
                    final activeBudget = state.activeBudget;
                    if (activeBudget != null) {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            DuplicationDialog(sourceBudget: activeBudget),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No active budget to duplicate.'),
                        ),
                      );
                    }
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                final currentPeriod = context
                    .read<NavigationBloc>()
                    .state
                    .currentPeriod;
                context.read<BudgetBloc>().add(
                  LoadSummaryEvent(period: currentPeriod),
                );
              },
            ),
            BlocBuilder<NavigationBloc, NavigationState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.currency_exchange),
                  tooltip: 'Convert Currency',
                  onPressed: state.activeBudget != null
                      ? () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => BlocProvider.value(
                              value: context.read<BudgetBloc>(),
                              child: CurrencyConversionDialog(
                                budget: state.activeBudget!,
                              ),
                            ),
                          );
                        }
                      : null,
                );
              },
            ),
            BlocBuilder<NavigationBloc, NavigationState>(
              builder: (context, state) {
                return IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: state.activeBudget != null
                        ? Colors.red
                        : Colors.grey,
                  ),
                  tooltip: 'Delete Budget',
                  onPressed: state.activeBudget != null
                      ? () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Budget'),
                              content: Text(
                                'Are you sure you want to delete "${state.activeBudget!.name}"? This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true && context.mounted) {
                            context.read<BudgetBloc>().add(
                              DeleteBudgetEvent(state.activeBudget!.id),
                            );
                          }
                        }
                      : null,
                );
              },
            ),
          ],
        ),
        drawer: const NavigationDrawerWidget(),
        body: BlocConsumer<BudgetBloc, BudgetState>(
          listener: (context, state) {
            if (state is CategoriesLoaded) {
              setState(() {
                _categories = state.categories;
              });
            }
            if (state is SummaryLoaded) {
              setState(() {
                _lastSummary = state.summary;
              });
            }
            if (state is IncomeAdded ||
                state is ExpenseAdded ||
                state is EntryDeleted ||
                state is EntryUpdated ||
                state is BudgetDeleted ||
                state is BudgetsCleared ||
                state is FactoryResetComplete) {
              final navState = context.read<NavigationBloc>().state;
              context.read<BudgetBloc>().add(
                LoadSummaryEvent(
                  period: navState.currentPeriod,
                  budgetId: navState.activeBudget?.id,
                ),
              );
              context.read<ProjectionBloc>().add(const LoadProjection());

              if (state is EntryDeleted || state is EntryUpdated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state is EntryDeleted ? 'Entry deleted' : 'Entry updated',
                    ),
                  ),
                );
              }
              if (state is BudgetDeleted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Budget deleted')));
                final navState = context.read<NavigationBloc>().state;
                context.read<NavigationBloc>().add(
                  ChangePeriod(navState.currentPeriod),
                );
              }
              if (state is BudgetsCleared) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All budgets cleared')),
                );
                final navState = context.read<NavigationBloc>().state;
                context.read<NavigationBloc>().add(
                  ChangePeriod(navState.currentPeriod),
                );
              }
              if (state is FactoryResetComplete) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Factory reset complete')),
                );
                final navState = context.read<NavigationBloc>().state;
                context.read<NavigationBloc>().add(
                  ChangePeriod(navState.currentPeriod),
                );
              }
            }
          },
          builder: (context, state) {
            if (_lastSummary == null &&
                (state is BudgetInitial || state is BudgetLoading)) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading...'),
                  ],
                ),
              );
            }

            if (state is BudgetError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final currentPeriod = context
                            .read<NavigationBloc>()
                            .state
                            .currentPeriod;
                        context.read<BudgetBloc>().add(
                          LoadSummaryEvent(period: currentPeriod),
                        );
                        context.read<BudgetBloc>().add(
                          const LoadCategoriesEvent(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final summary = state is SummaryLoaded
                ? state.summary
                : _lastSummary;

            return Column(
              children: [
                if (state is BudgetLoading) const LinearProgressIndicator(),
                const HomeProjectionOverview(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (summary != null) ...[
                          SummaryCard(summary: summary),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final budgetId = context
                                        .read<NavigationBloc>()
                                        .state
                                        .activeBudget
                                        ?.id;
                                    if (budgetId == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('No active budget'),
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() {
                                      _showIncomeForm = true;
                                    });
                                    _showTransactionDialog(context, budgetId);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Income'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final budgetId = context
                                        .read<NavigationBloc>()
                                        .state
                                        .activeBudget
                                        ?.id;
                                    if (budgetId == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('No active budget'),
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() {
                                      _showIncomeForm = false;
                                    });
                                    _showTransactionDialog(context, budgetId);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  icon: const Icon(Icons.remove),
                                  label: const Text('Add Expense'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (summary != null) ...[
                          ExpansionTile(
                            initiallyExpanded: true,
                            title: ListHeaderTotal(
                              label: 'Income',
                              actualTotal: summary.totalIncome,
                              potentialTotal: summary.totalPotentialIncome,
                            ),
                            leading: const Icon(
                              Icons.arrow_downward,
                              color: Colors.green,
                            ),
                            children: [
                              IncomeList(
                                entries: summary.incomeEntries,
                                onEdit: (entry) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => TransactionEditDialog(
                                      income: entry,
                                      categories: _categories,
                                    ),
                                  );
                                },
                                onConfirm: (entry) {
                                  context.read<BudgetBloc>().add(
                                    ConfirmPotentialTransactionEvent(
                                      incomeId: entry.id,
                                    ),
                                  );
                                },
                                onDelete: (entry) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => DeleteConfirmationDialog(
                                      title: 'Delete Income',
                                      content:
                                          'Are you sure you want to delete this income entry?',
                                      onConfirm: () {
                                        context.read<BudgetBloc>().add(
                                          DeleteEntryEvent(
                                            entry.id,
                                            EntryType.income,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ExpansionTile(
                            initiallyExpanded: true,
                            title: ListHeaderTotal(
                              label: 'Expenses',
                              actualTotal: summary.totalExpenses,
                              potentialTotal: summary.totalPotentialExpenses,
                            ),
                            leading: const Icon(
                              Icons.arrow_upward,
                              color: Colors.red,
                            ),
                            children: [
                              ExpenseList(
                                entries: summary.expenseEntries,
                                onEdit: (entry) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => TransactionEditDialog(
                                      expense: entry,
                                      categories: _categories,
                                    ),
                                  );
                                },
                                onConfirm: (entry) {
                                  context.read<BudgetBloc>().add(
                                    ConfirmPotentialTransactionEvent(
                                      expenseId: entry.id,
                                    ),
                                  );
                                },
                                onDelete: (entry) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => DeleteConfirmationDialog(
                                      title: 'Delete Expense',
                                      content:
                                          'Are you sure you want to delete this expense entry?',
                                      onConfirm: () {
                                        context.read<BudgetBloc>().add(
                                          DeleteEntryEvent(
                                            entry.id,
                                            EntryType.expense,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showTransactionDialog(BuildContext context, String budgetId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_showIncomeForm ? 'Add Income' : 'Add Expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showIncomeForm)
                IncomeForm(
                  categories: _categories
                      .where((c) => c.type == CategoryType.income)
                      .toList(),
                  onSubmit:
                      (
                        id,
                        amount,
                        categoryId,
                        description,
                        date, {
                        bool isRecurring = false,
                        int? interval,
                        RecurrenceUnit? unit,
                        DateTime? endDate,
                        bool isPotential = false,
                      }) {
                        if (isRecurring && interval != null && unit != null) {
                          context.read<BudgetBloc>().add(
                            SaveRecurringTransactionEvent(
                              RecurringTransaction(
                                id: _uuid.v4(),
                                budgetId: budgetId,
                                type: 'INCOME',
                                amount: amount,
                                categoryId: categoryId,
                                description: description ?? 'Recurring Income',
                                startDate: date,
                                endDate: endDate,
                                interval: interval,
                                unit: unit,
                              ),
                            ),
                          );
                        } else {
                          context.read<BudgetBloc>().add(
                            AddIncomeEvent(
                              id: id,
                              budgetId: budgetId,
                              amount: amount,
                              categoryId: categoryId,
                              description: description,
                              date: date,
                              isPotential: isPotential,
                            ),
                          );
                        }
                        Navigator.pop(context);
                      },
                )
              else
                ExpenseForm(
                  categories: _categories
                      .where((c) => c.type == CategoryType.expense)
                      .toList(),
                  onSubmit:
                      (
                        id,
                        amount,
                        categoryId,
                        description,
                        date, {
                        bool isRecurring = false,
                        int? interval,
                        RecurrenceUnit? unit,
                        DateTime? endDate,
                        bool isPotential = false,
                      }) {
                        if (isRecurring && interval != null && unit != null) {
                          context.read<BudgetBloc>().add(
                            SaveRecurringTransactionEvent(
                              RecurringTransaction(
                                id: _uuid.v4(),
                                budgetId: budgetId,
                                type: 'EXPENSE',
                                amount: amount,
                                categoryId: categoryId,
                                description: description ?? 'Recurring Expense',
                                startDate: date,
                                endDate: endDate,
                                interval: interval,
                                unit: unit,
                              ),
                            ),
                          );
                        } else {
                          context.read<BudgetBloc>().add(
                            AddExpenseEvent(
                              id: id,
                              budgetId: budgetId,
                              amount: amount,
                              category: categoryId,
                              description: description,
                              date: date,
                              isPotential: isPotential,
                            ),
                          );
                        }
                        Navigator.pop(context);
                      },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
