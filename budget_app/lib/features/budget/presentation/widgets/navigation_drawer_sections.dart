import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/budget/presentation/pages/disposable_history_page.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';
import '../bloc/navigation_bloc.dart';
import 'dispose_persist_sheet.dart';

/// Safely closes the modal Scaffold drawer if one is currently open,
/// without popping the active page route when the drawer is docked inline.
void closeDrawerIfOpen(BuildContext context) {
  final scaffoldState = Scaffold.maybeOf(context);
  if (scaffoldState != null && scaffoldState.isDrawerOpen) {
    Navigator.of(context).pop();
  }
}

/// Displays active disposable budgets and history navigation in the drawer.
class NavigationDisposableSection extends StatefulWidget {
  const NavigationDisposableSection({super.key});

  @override
  State<NavigationDisposableSection> createState() =>
      _NavigationDisposableSectionState();
}

class _NavigationDisposableSectionState
    extends State<NavigationDisposableSection> {
  bool _promptedEnded = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        final bloc = context.read<BudgetBloc>();
        final useCache = state is SummaryLoaded || state is CategoriesLoaded;
        List<Budget> active = const <Budget>[];
        Map<String, double> budgetExpenseTotals = const <String, double>{};
        Set<String> endedBudgetIds = const <String>{};

        if (state is DisposableBudgetsLoaded) {
          active = state.active;
          budgetExpenseTotals = state.budgetExpenseTotals;
          endedBudgetIds = state.endedBudgetIds;
        } else if (useCache) {
          try {
            active = bloc.cachedActiveDisposableBudgets;
            budgetExpenseTotals = bloc.cachedBudgetExpenseTotals;
            endedBudgetIds = bloc.cachedEndedBudgetIds;
          } catch (_) {}
        }

        if ((state is DisposableBudgetsLoaded || active.isNotEmpty) &&
            endedBudgetIds.isNotEmpty &&
            !_promptedEnded) {
          _promptedEnded = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${endedBudgetIds.length} disposable budget(s) have ended. Tap to dispose or persist.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          });
        }

        if (active.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Disposable Budgets',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              ...active.map((budget) {
                final expenses = budgetExpenseTotals[budget.id] ?? 0.0;
                final remaining = budget.targetIncome != null
                    ? budget.targetIncome! - expenses
                    : 0.0;
                final isEnded = endedBudgetIds.contains(budget.id);
                return ListTile(
                  leading: Icon(
                    isEnded ? Icons.warning_amber : Icons.all_inbox,
                    color: isEnded
                        ? Colors.amber
                        : Theme.of(context).colorScheme.secondary,
                    size: 20,
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          budget.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      if (isEnded)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            '(ended)',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.amber.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    '\$${budget.targetIncome?.toStringAsFixed(2) ?? '0.00'} - \$${remaining.toStringAsFixed(2)} remaining',
                    style: TextStyle(
                      fontSize: 12,
                      color: remaining > 0
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onSelected: (value) {
                      if (value == 'dispose' || value == 'persist') {
                        closeDrawerIfOpen(context);
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => DisposePersistSheet(
                            budget: budget,
                            totalExpenses: expenses,
                          ),
                        );
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'dispose',
                        child: ListTile(
                          leading: Icon(Icons.archive),
                          title: Text('Dispose'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'persist',
                        child: ListTile(
                          leading: Icon(Icons.save),
                          title: Text('Persist'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  dense: true,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => DisposePersistSheet(
                        budget: budget,
                        totalExpenses: expenses,
                      ),
                    );
                  },
                );
              }),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: TextButton.icon(
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('View History'),
                  onPressed: () {
                    closeDrawerIfOpen(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DisposableHistoryPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        if (state is DisposableBudgetsLoaded ||
            state is SummaryLoaded ||
            state is CategoriesLoaded) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextButton.icon(
              icon: const Icon(Icons.history, size: 18),
              label: const Text('View Disposable History'),
              onPressed: () {
                closeDrawerIfOpen(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DisposableHistoryPage(),
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Shows the dialog to clone a budget to a target period.
Future<bool> showCloneBudgetDialog({
  required BuildContext context,
  required Budget sourceBudget,
}) async {
  final next = BudgetPeriod.fromDate(
    DateTime(sourceBudget.periodYear, sourceBudget.periodMonth),
  ).next;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(
    text: '${sourceBudget.name} (Copy)',
  );
  var targetYear = next.year;
  var targetMonth = next.month;
  var includeTransactions = false;

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (ctx, setLocalState) {
          final targetLabel = DateFormat(
            'MMMM yyyy',
          ).format(DateTime(targetYear, targetMonth));
          final sourceLabel = DateFormat('MMMM yyyy').format(
            DateTime(sourceBudget.periodYear, sourceBudget.periodMonth),
          );

          Future<void> pickDate() async {
            final picked = await showDatePicker(
              context: ctx,
              initialDate: DateTime(targetYear, targetMonth),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDatePickerMode: DatePickerMode.year,
              helpText: 'Select target month',
            );
            if (picked != null) {
              setLocalState(() {
                targetYear = picked.year;
                targetMonth = picked.month;
              });
            }
          }

          return AlertDialog(
            title: const Text('Clone Budget'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From: ${sourceBudget.name} ($sourceLabel)',
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event),
                      title: const Text('To'),
                      subtitle: Text(targetLabel),
                      trailing: const Icon(Icons.edit_calendar),
                      onTap: pickDate,
                    ),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Include transactions'),
                      value: includeTransactions,
                      onChanged: (v) {
                        setLocalState(() {
                          includeTransactions = v;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) {
                    return;
                  }
                  Navigator.pop(dialogContext, true);
                },
                child: Text(
                  'Clone',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );

  if (result != true || !context.mounted) {
    nameController.dispose();
    return false;
  }

  final targetPeriod = BudgetPeriod(year: targetYear, month: targetMonth);
  final trimmedName = nameController.text.trim();
  context.read<BudgetBloc>().add(
    DuplicateBudgetEvent(
      sourceBudget: sourceBudget,
      targetPeriod: targetPeriod,
      newName: trimmedName,
      includeTransactions: includeTransactions,
    ),
  );
  context.read<NavigationBloc>().add(ChangePeriod(targetPeriod));
  nameController.dispose();
  return true;
}
