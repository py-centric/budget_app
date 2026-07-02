import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:budget_app/shared/widgets/confirm_action_dialog.dart';
import '../bloc/navigation_bloc.dart';
import 'year_group_header.dart';
import '../pages/category_settings_page.dart';
import '../pages/projection_page.dart';
import '../pages/manage_recurring_page.dart';
import '../pages/category_breakdown_page.dart';
import 'package:budget_app/features/settings/presentation/pages/settings_page.dart';
import 'package:budget_app/features/financial_tools/presentation/pages/tools_hub_page.dart';

import 'package:budget_app/features/business_tools/presentation/pages/invoices_page.dart';
import 'package:budget_app/features/business_tools/presentation/pages/clients_page.dart';
import 'package:budget_app/features/business_tools/presentation/pages/profile_settings_page.dart';
import 'package:budget_app/features/accounts/presentation/pages/accounts_page.dart';
import 'package:budget_app/features/savings/presentation/pages/savings_goals_page.dart';
import 'package:budget_app/features/reminders/presentation/pages/reminders_page.dart';
import 'package:budget_app/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:budget_app/features/reminders/presentation/bloc/reminder_state.dart';
import 'package:budget_app/features/budget/presentation/pages/budget_comparison_page.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';
import 'package:budget_app/features/budget/domain/entities/budget_period.dart';
import 'package:budget_app/features/calendar/presentation/pages/calendar_view_page.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import 'create_budget_dialog.dart';

class NavigationDrawerWidget extends StatefulWidget {
  const NavigationDrawerWidget({super.key});

  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  final Map<int, bool> _expandedYears = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        final sortedYears =
            state.availablePeriods.map((p) => p.year).toSet().toList()
              ..sort((a, b) => b.compareTo(a));

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Center(
                  child: Text(
                    'Budget App',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.pie_chart),
                title: const Text('Category Breakdown'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoryBreakdownPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Manage Categories'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategorySettingsPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_up),
                title: const Text('Projections'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProjectionPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.autorenew),
                title: const Text('Recurring Transactions'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageRecurringPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.calculate),
                title: const Text('Financial Tools'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ToolsHubPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('Accounts'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountsPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.savings),
                title: const Text('Savings Goals'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavingsGoalsPage(),
                    ),
                  );
                },
              ),
              BlocBuilder<ReminderBloc, ReminderState>(
                builder: (context, state) {
                  final unreadCount = state is ReminderLoaded
                      ? state.unreadCount
                      : 0;
                  return ListTile(
                    leading: Stack(
                      children: [
                        const Icon(Icons.notifications),
                        if (unreadCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onError,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: const Text('Bill Reminders'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RemindersPage(),
                        ),
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.compare_arrows),
                title: const Text('Budget Comparison'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BudgetComparisonPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Calendar View'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalendarViewPage(),
                    ),
                  );
                },
              ),
              ExpansionTile(
                leading: const Icon(Icons.business_center),
                title: const Text('Business Tools'),
                children: [
                  ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: const Text('Invoices'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InvoicesPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Clients'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ClientsPage(),
                        ), // To be created
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.store),
                    title: const Text('Profiles'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileSettingsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.settings_applications),
                title: const Text('App Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.add_box_outlined, color: Theme.of(context).colorScheme.primary),
                title: Text('Create Budget', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => const CreateBudgetDialog(),
                  );
                },
              ),

              const Divider(),
              ...List.generate(sortedYears.length, (index) {
                final year = sortedYears[index];
                final monthsInYear =
                    state.availablePeriods.where((p) => p.year == year).toList()
                      ..sort((a, b) => b.month.compareTo(a.month));

                final isExpanded = _expandedYears[year] ?? (index == 0);

                return Column(
                  children: [
                    YearGroupHeader(
                      year: year,
                      isExpanded: isExpanded,
                      onTap: () {
                        setState(() {
                          _expandedYears[year] = !isExpanded;
                        });
                      },
                    ),
                    if (isExpanded)
                      ...monthsInYear.map(
                        (period) {
                          Budget? sourceBudget;
                          for (final b in state.availableBudgetsForPeriod) {
                            if (b.periodMonth == period.month &&
                                b.periodYear == period.year) {
                              sourceBudget = b;
                              break;
                            }
                          }

                          return Dismissible(
                            key: ValueKey('period_${period.year}_${period.month}'),
                            direction: DismissDirection.horizontal,
                            background: Container(
                              color: Theme.of(context).colorScheme.primary,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              child: Icon(Icons.copy, color: Theme.of(context).colorScheme.onPrimary),
                            ),
                            secondaryBackground: Container(
                              color: Theme.of(context).colorScheme.error,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
                            ),
                            confirmDismiss: (direction) async {
                              if (sourceBudget == null) return false;

                              if (direction == DismissDirection.startToEnd) {
                                return _showCloneDialog(
                                  context: context,
                                  sourceBudget: sourceBudget,
                                );
                              }

                              if (direction == DismissDirection.endToStart) {
                                final budgetName = sourceBudget.name;
                                final budgetId = sourceBudget.id;
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => ConfirmActionDialog(
                                    title: 'Delete Budget',
                                    message: 'Are you sure you want to delete "$budgetName"? All income and expense entries for this budget will also be deleted. This action cannot be undone.',
                                    confirmLabel: 'Delete',
                                    isDestructive: true,
                                    onConfirm: () => Navigator.pop(ctx, true),
                                  ),
                                );

                                if (confirmed == true && context.mounted) {
                                  context.read<BudgetBloc>().add(
                                    DeleteBudgetEvent(budgetId),
                                  );
                                }
                                return confirmed == true;
                              }

                              return false;
                            },
                            child: ListTile(
                              title: Text(
                                DateFormat('MMMM').format(DateTime(year, period.month)),
                              ),
                              selected: state.currentPeriod == period,
                              onTap: () {
                                context.read<NavigationBloc>().add(
                                  ChangePeriod(period),
                                );
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _showCloneDialog({
    required BuildContext context,
    required Budget sourceBudget,
  }) async {
    final next = BudgetPeriod.fromDate(DateTime(sourceBudget.periodYear, sourceBudget.periodMonth))
        .next;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: '${sourceBudget.name} (Copy)');
    var targetYear = next.year;
    var targetMonth = next.month;
    var includeTransactions = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            final targetLabel = DateFormat('MMMM yyyy').format(
              DateTime(targetYear, targetMonth),
            );
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
                      SwitchListTile(
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
                  child: Text('Clone', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) {
      nameController.dispose();
      return false;
    }

    if (!context.mounted) {
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
}
