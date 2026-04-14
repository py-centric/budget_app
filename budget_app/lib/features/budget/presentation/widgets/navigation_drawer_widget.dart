import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/navigation_bloc.dart';
import 'year_group_header.dart';
import '../pages/category_settings_page.dart';
import '../pages/projection_page.dart';
import '../pages/manage_recurring_page.dart';
import 'package:budget_app/features/settings/presentation/pages/settings_page.dart';
import 'package:budget_app/features/financial_tools/presentation/pages/tools_hub_page.dart';

import 'package:budget_app/features/business_tools/presentation/pages/invoices_page.dart';
import 'package:budget_app/features/business_tools/presentation/pages/clients_page.dart';
import 'package:budget_app/features/business_tools/presentation/pages/profile_settings_page.dart';
import 'package:budget_app/features/accounts/presentation/pages/accounts_page.dart';
import 'package:budget_app/features/savings/presentation/pages/savings_goals_page.dart';

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
                        (period) => ListTile(
                          title: Text(
                            DateFormat(
                              'MMMM',
                            ).format(DateTime(year, period.month)),
                          ),
                          selected: state.currentPeriod == period,
                          onTap: () {
                            context.read<NavigationBloc>().add(
                              ChangePeriod(period),
                            );
                            Navigator.pop(context);
                          },
                        ),
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
}
