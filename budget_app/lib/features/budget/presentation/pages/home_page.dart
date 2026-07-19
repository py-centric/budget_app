import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:budget_app/core/theme/app_spacing.dart';
import 'package:budget_app/shared/widgets/confirm_action_dialog.dart';

import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';
import '../bloc/navigation_bloc.dart';
import '../bloc/category_bloc.dart';
import '../widgets/transaction_form.dart';
import '../widgets/income_list.dart';
import '../widgets/expense_list.dart';
import '../widgets/summary_card.dart';
import '../widgets/outstanding_balances_card.dart';
import '../widgets/navigation_drawer_widget.dart';
import '../widgets/transaction_edit_dialog.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../widgets/home_projection_overview.dart';
import '../widgets/duplication_dialog.dart';
import '../widgets/budget_selector.dart';
import '../widgets/currency_conversion_dialog.dart';
import '../widgets/filter_bar.dart';
import '../widgets/category_limit_card.dart';
import '../widgets/category_limit_dialog.dart';
import '../widgets/split_transaction_dialog.dart';
import '../bloc/projection_bloc.dart';
import '../bloc/category_limit_bloc.dart';
import '../bloc/category_limit_event.dart';
import '../bloc/category_limit_state.dart';
import '../bloc/projection_event.dart';
import 'package:budget_app/shared/widgets/branding_footer.dart';
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
          budgetId: navState.budgetIdForPeriod(navState.currentPeriod),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, NavigationState>(
      listenWhen: (previous, current) =>
          previous.currentPeriod != current.currentPeriod,
      listener: (context, navState) {
        context.read<BudgetBloc>().add(
          LoadSummaryEvent(
            period: navState.currentPeriod,
            budgetId: navState.budgetIdForPeriod(navState.currentPeriod),
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
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.outline,
                  ),
                  tooltip: 'Delete Budget',
                  onPressed: state.activeBudget != null
                      ? () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => ConfirmActionDialog(
                              title: 'Delete Budget',
                              message: 'Are you sure you want to delete "${state.activeBudget!.name}"? This action cannot be undone.',
                              confirmLabel: 'Delete',
                              isDestructive: true,
                              onConfirm: () => Navigator.pop(ctx, true),
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
        body: BlocListener<BudgetBloc, BudgetState>(
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
            if (state is OperationSuccess) {
              final navState = context.read<NavigationBloc>().state;
              context.read<BudgetBloc>().add(
                LoadSummaryEvent(
                  period: navState.currentPeriod,
                  budgetId: navState.budgetIdForPeriod(navState.currentPeriod),
                ),
              );
              context.read<ProjectionBloc>().add(const LoadProjection());

              final snackText = state.message ?? 'Operation completed';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(snackText)),
              );
            }
          },
          child: BlocBuilder<BudgetBloc, BudgetState>(
            buildWhen: (previous, current) {
              if (current is BudgetInitial ||
                  current is BudgetLoading ||
                  current is BudgetError) {
                return true;
              }
              if (current is SummaryLoaded) return true;
              return false;
            },
            builder: (context, state) {
              if (_lastSummary == null &&
                  (state is BudgetInitial || state is BudgetLoading)) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: AppSpacing.md),
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
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text('Error: ${state.message}'),
                      SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () {
                          final navState = context
                              .read<NavigationBloc>()
                              .state;
                          context.read<BudgetBloc>().add(
                            LoadSummaryEvent(
                              period: navState.currentPeriod,
                              budgetId: navState.budgetIdForPeriod(navState.currentPeriod),
                            ),
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

              return Column(
                children: [
                  if (state is BudgetLoading) const LinearProgressIndicator(),
                  const HomeProjectionOverview(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          BlocBuilder<BudgetBloc, BudgetState>(
                            buildWhen: (previous, current) =>
                                current is SummaryLoaded ||
                                current is BudgetError,
                            builder: (context, state) {
                              final s = state is SummaryLoaded
                                  ? state.summary
                                  : _lastSummary;
                              if (s == null) return const SizedBox.shrink();
                              return Column(
                                children: [
                                  SummaryCard(summary: s),
                                  const SizedBox(height: AppSpacing.md),
                                  OutstandingBalancesCard(summary: s),
                                  const SizedBox(height: AppSpacing.lg),
                                  _buildCategoryLimitsSection(context, s),
                                  SizedBox(height: AppSpacing.lg),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FilledButton.icon(
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
                                                  content: Text(
                                                    'No active budget',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            setState(() {
                                              _showIncomeForm = true;
                                            });
                                            _showTransactionDialog(
                                              context,
                                              budgetId,
                                            );
                                          },
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.primary,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: AppSpacing.md,
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
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: FilledButton.icon(
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
                                                  content: Text(
                                                    'No active budget',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            setState(() {
                                              _showIncomeForm = false;
                                            });
                                            _showTransactionDialog(
                                              context,
                                              budgetId,
                                            );
                                          },
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.error,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: AppSpacing.md,
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
                                  SizedBox(height: AppSpacing.lg),
                                ],
                              );
                            },
                          ),
                          BlocBuilder<BudgetBloc, BudgetState>(
                            buildWhen: (previous, current) =>
                                current is SummaryLoaded,
                            builder: (context, state) {
                              final s = state is SummaryLoaded
                                  ? state.summary
                                  : _lastSummary;
                              if (s == null) return const SizedBox.shrink();
                              return FilterBar(
                                incomeEntries: s.incomeEntries,
                                expenseEntries: s.expenseEntries,
                                onEditIncome: (entry) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => TransactionEditDialog(
                                      income: entry,
                                      categories: _categories,
                                    ),
                                  );
                                },
                                onDeleteIncome: (entry) {
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
                                onConfirmIncome: (entry) {
                                  context.read<BudgetBloc>().add(
                                    ConfirmPotentialTransactionEvent(
                                      incomeId: entry.id,
                                    ),
                                  );
                                },
                                onEditExpense: (entry) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => TransactionEditDialog(
                                      expense: entry,
                                      categories: _categories,
                                    ),
                                  );
                                },
                                onDeleteExpense: (entry) {
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
                                onConfirmExpense: (entry) {
                                  context.read<BudgetBloc>().add(
                                    ConfirmPotentialTransactionEvent(
                                      expenseId: entry.id,
                                    ),
                                  );
                                },
                                incomeListBuilder:
                                    (entries, onEdit, onDelete, onConfirm, sortField, sortOrder, groupMode) {
                                      return IncomeList(
                                        entries: entries,
                                        onEdit: onEdit,
                                        onDelete: onDelete,
                                        onConfirm: onConfirm,
                                        sortField: sortField,
                                        sortOrder: sortOrder,
                                        groupMode: groupMode,
                                      );
                                    },
                                expenseListBuilder:
                                    (entries, onEdit, onDelete, onConfirm, sortField, sortOrder, groupMode) {
                                      return ExpenseList(
                                        entries: entries,
                                        onEdit: onEdit,
                                        onDelete: onDelete,
                                        onConfirm: onConfirm,
                                        sortField: sortField,
                                        sortOrder: sortOrder,
                                        groupMode: groupMode,
                                      );
                                    },
                              );
                            },
                          ),
                          const BrandingFooter(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showTransactionDialog(BuildContext context, String budgetId) {
    final navState = context.read<NavigationBloc>().state;
    final period = navState.currentPeriod;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_showIncomeForm ? 'Add Income' : 'Add Expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TransactionForm(
                isIncome: _showIncomeForm,
                categories: _categories
                    .where(
                      (c) =>
                          c.type ==
                          (_showIncomeForm
                              ? CategoryType.income
                              : CategoryType.expense),
                    )
                    .toList(),
                periodYear: period.year,
                periodMonth: period.month,
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
                      List<SplitItem>? splits,
                      String? targetBudgetId,
                    }) {
                      final effectiveBudgetId = targetBudgetId ?? budgetId;

                      if (isRecurring && interval != null && unit != null) {
                        context.read<BudgetBloc>().add(
                          SaveRecurringTransactionEvent(
                            RecurringTransaction(
                              id: _uuid.v4(),
                              budgetId: effectiveBudgetId,
                              type: _showIncomeForm ? 'INCOME' : 'EXPENSE',
                              amount: amount,
                              categoryId: categoryId,
                              description:
                                  description ??
                                  (_showIncomeForm
                                      ? 'Recurring Income'
                                      : 'Recurring Expense'),
                              startDate: date,
                              endDate: endDate,
                              interval: interval,
                              unit: unit,
                            ),
                          ),
                        );
                      } else if (_showIncomeForm) {
                        context.read<BudgetBloc>().add(
                          AddIncomeEvent(
                            id: id,
                            budgetId: effectiveBudgetId,
                            amount: amount,
                            categoryId: categoryId,
                            description: description,
                            date: date,
                            isPotential: isPotential,
                          ),
                        );
                      } else {
                        context.read<BudgetBloc>().add(
                          AddExpenseEvent(
                            id: id,
                            budgetId: effectiveBudgetId,
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

  Widget _buildCategoryLimitsSection(
    BuildContext context,
    BudgetSummary summary,
  ) {
    final navState = context.read<NavigationBloc>().state;
    final budgetId = navState.activeBudget?.id;

    if (budgetId == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Category Limits',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => _showAddLimitDialog(context, budgetId),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Limit'),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        BlocBuilder<CategoryLimitBloc, CategoryLimitState>(
          builder: (context, state) {
            if (state is CategoryLimitLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CategoryLimitLoaded) {
              if (state.limits.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Center(
                        child: Text(
                          'No category limits set. Tap "Add Limit" to get started.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                    ),
                  ),
                );
              }

              return Column(
                children: state.limits.map((limitWithSpending) {
                  return CategoryLimitCard(
                    limitWithSpending: limitWithSpending,
                    onEdit: () => _showEditLimitDialog(
                      context,
                      budgetId,
                      limitWithSpending,
                    ),
                    onDelete: () =>
                        _deleteLimit(context, limitWithSpending.limit.id),
                  );
                }).toList(),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _showAddLimitDialog(BuildContext context, String budgetId) {
    final categoryState = context.read<CategoryBloc>().state;
    final categories = categoryState is CategoriesLoadedState
        ? categoryState.categories
        : <Category>[];
    final bloc = context.read<CategoryLimitBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => CategoryLimitDialog(
        categories: categories,
        onSave: (categoryId, amount, period) {
          bloc.add(
            AddCategoryLimit(
              categoryId: categoryId,
              amount: amount,
              period: period,
              budgetId: budgetId,
            ),
          );
        },
      ),
    );
  }

  void _showEditLimitDialog(
    BuildContext context,
    String budgetId,
    CategoryLimitWithSpending limitWithSpending,
  ) {
    final categoryState = context.read<CategoryBloc>().state;
    final categories = categoryState is CategoriesLoadedState
        ? categoryState.categories
        : <Category>[];
    final bloc = context.read<CategoryLimitBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => CategoryLimitDialog(
        categories: categories,
        existingLimit: limitWithSpending.limit,
        onSave: (categoryId, amount, period) {
          bloc.add(
            UpdateCategoryLimit(
              limitWithSpending.limit.copyWith(
                categoryId: categoryId,
                amount: amount,
                period: period,
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteLimit(BuildContext context, String limitId) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmActionDialog(
        title: 'Delete Limit',
        message: 'Are you sure you want to delete this category limit?',
        confirmLabel: 'Delete',
        isDestructive: true,
        onConfirm: () {
          context.read<CategoryLimitBloc>().add(
            DeleteCategoryLimit(limitId),
          );
        },
      ),
    );
  }
}
