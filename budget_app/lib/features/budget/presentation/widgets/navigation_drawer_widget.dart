import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:budget_app/core/feature_flags/models/feature_flag.dart';
import 'package:budget_app/core/feature_flags/presentation/widgets/feature_gate.dart';
import 'package:budget_app/shared/widgets/confirm_action_dialog.dart';
import 'package:budget_app/shared/widgets/pycentric_footer_widget.dart';
import '../bloc/navigation_bloc.dart';
import 'year_group_header.dart';
import '../pages/home_page.dart';
import '../pages/category_settings_page.dart';
import '../pages/projection_page.dart';
import '../pages/manage_recurring_page.dart';
import '../pages/category_breakdown_page.dart';
import 'package:budget_app/features/settings/presentation/pages/settings_page.dart';
import 'package:budget_app/features/financial_tools/presentation/pages/tools_hub_page.dart';
import 'package:budget_app/features/business_tools/presentation/pages/invoices_page.dart';
import 'package:budget_app/features/business_tools/presentation/pages/clients_page.dart';
import 'package:budget_app/features/business_tools/presentation/pages/profile_settings_page.dart';
import 'package:budget_app/features/loans/presentation/pages/loans_page.dart';
import 'package:budget_app/features/accounts/presentation/pages/accounts_page.dart';
import 'package:budget_app/features/credit_cards/presentation/pages/credit_cards_page.dart';
import 'package:budget_app/features/investments/presentation/pages/investments_page.dart';
import 'package:budget_app/features/budget_templates/presentation/pages/budget_templates_page.dart';
import 'package:budget_app/features/recurring_templates/presentation/pages/recurring_templates_page.dart';
import 'package:budget_app/features/tags/presentation/pages/tags_page.dart';
import 'package:budget_app/features/dashboard_customization/presentation/pages/dashboard_settings_page.dart';
import 'package:budget_app/features/savings/presentation/pages/savings_goals_page.dart';
import 'package:budget_app/features/reminders/presentation/pages/reminders_page.dart';
import 'package:budget_app/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:budget_app/features/reminders/presentation/bloc/reminder_state.dart';
import 'package:budget_app/features/budget/presentation/pages/budget_comparison_page.dart';
import 'package:budget_app/features/budget/domain/entities/budget.dart';
import 'package:budget_app/features/calendar/presentation/pages/calendar_view_page.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import 'create_budget_dialog.dart';
import 'create_disposable_dialog.dart';
import 'package:budget_app/shared/widgets/workspace_destination.dart';
import 'navigation_drawer_sections.dart';

class NavigationDrawerWidget extends StatefulWidget {
  final VoidCallback? onToggleCollapse;
  final WorkspaceDestination? activeDestination;

  const NavigationDrawerWidget({
    super.key,
    this.onToggleCollapse,
    this.activeDestination,
  });

  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  final Map<int, bool> _expandedYears = {};
  String? _activeRowTitle;

  /// Drawer row metadata. Each row's [WorkspaceDrawerRow.destination] MUST
  /// equal the `selectedIndex` its target page declares on its workspace
  /// shell so navbar, rail and drawer can never disagree (FR-013).
  static const Map<String, WorkspaceDrawerRow> _drawerRows = {
    'Dashboard Overview': WorkspaceDrawerRow(
      title: 'Dashboard Overview',
      pageType: HomePage,
      destination: WorkspaceDestination.overview,
      isFamilyAnchor: true,
    ),
    'Category Breakdown': WorkspaceDrawerRow(
      title: 'Category Breakdown',
      pageType: CategoryBreakdownPage,
      destination: WorkspaceDestination.breakdown,
      isFamilyAnchor: true,
    ),
    'Manage Categories': WorkspaceDrawerRow(
      title: 'Manage Categories',
      pageType: CategorySettingsPage,
      destination: WorkspaceDestination.preferences,
    ),
    'Projections': WorkspaceDrawerRow(
      title: 'Projections',
      pageType: ProjectionPage,
      destination: WorkspaceDestination.breakdown,
    ),
    'Recurring Transactions': WorkspaceDrawerRow(
      title: 'Recurring Transactions',
      pageType: ManageRecurringPage,
      destination: WorkspaceDestination.overview,
    ),
    'Financial Tools': WorkspaceDrawerRow(
      title: 'Financial Tools',
      pageType: ToolsHubPage,
      destination: WorkspaceDestination.tools,
      isFamilyAnchor: true,
    ),
    'Accounts': WorkspaceDrawerRow(
      title: 'Accounts',
      pageType: AccountsPage,
      destination: WorkspaceDestination.wallet,
      isFamilyAnchor: true,
    ),
    'Savings Goals': WorkspaceDrawerRow(
      title: 'Savings Goals',
      pageType: SavingsGoalsPage,
      destination: WorkspaceDestination.wallet,
    ),
    'Bill Reminders': WorkspaceDrawerRow(
      title: 'Bill Reminders',
      pageType: RemindersPage,
      destination: WorkspaceDestination.overview,
    ),
    'Budget Comparison': WorkspaceDrawerRow(
      title: 'Budget Comparison',
      pageType: BudgetComparisonPage,
      destination: WorkspaceDestination.breakdown,
    ),
    'Calendar View': WorkspaceDrawerRow(
      title: 'Calendar View',
      pageType: CalendarViewPage,
      destination: WorkspaceDestination.overview,
    ),
    'Invoices': WorkspaceDrawerRow(
      title: 'Invoices',
      pageType: InvoicesPage,
      destination: WorkspaceDestination.tools,
    ),
    'Clients': WorkspaceDrawerRow(
      title: 'Clients',
      pageType: ClientsPage,
      destination: WorkspaceDestination.tools,
    ),
    'Loans': WorkspaceDrawerRow(
      title: 'Loans',
      pageType: LoansPage,
      destination: WorkspaceDestination.wallet,
    ),
    'Business Profile': WorkspaceDrawerRow(
      title: 'Business Profile',
      pageType: ProfileSettingsPage,
      destination: WorkspaceDestination.preferences,
    ),
    'App Settings': WorkspaceDrawerRow(
      title: 'App Settings',
      pageType: SettingsPage,
      destination: WorkspaceDestination.preferences,
      isFamilyAnchor: true,
    ),
    'Credit Cards': WorkspaceDrawerRow(
      title: 'Credit Cards',
      pageType: CreditCardsPage,
      destination: WorkspaceDestination.wallet,
    ),
    'Investments': WorkspaceDrawerRow(
      title: 'Investments',
      pageType: InvestmentsPage,
      destination: WorkspaceDestination.wallet,
    ),
    'Loans Tracker': WorkspaceDrawerRow(
      title: 'Loans Tracker',
      pageType: LoansPage,
      destination: WorkspaceDestination.wallet,
    ),
    'Budget Templates': WorkspaceDrawerRow(
      title: 'Budget Templates',
      pageType: BudgetTemplatesPage,
      destination: WorkspaceDestination.preferences,
    ),
    'Quick Add Templates': WorkspaceDrawerRow(
      title: 'Quick Add Templates',
      pageType: RecurringTemplatesPage,
      destination: WorkspaceDestination.preferences,
    ),
    'Manage Tags': WorkspaceDrawerRow(
      title: 'Manage Tags',
      pageType: TagsPage,
      destination: WorkspaceDestination.preferences,
    ),
    'Dashboard Layout': WorkspaceDrawerRow(
      title: 'Dashboard Layout',
      pageType: DashboardSettingsPage,
      destination: WorkspaceDestination.preferences,
    ),
  };

  /// Resolves the single drawer row to highlight: the row whose target page
  /// hosts this drawer (exact match), falling back to the anchor row of the
  /// declared destination family for pages that are not drawer rows
  /// (e.g. detail sub-pages).
  String? _resolveActiveRow(BuildContext context) {
    for (final WorkspaceDrawerRow row in _drawerRows.values) {
      if (row.isCurrentPage(context)) return row.title;
    }
    final WorkspaceDestination? active = widget.activeDestination;
    if (active != null) {
      for (final WorkspaceDrawerRow row in _drawerRows.values) {
        if (row.isFamilyAnchor && row.destination == active) return row.title;
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    try {
      context.read<BudgetBloc>().add(const LoadDisposableHistoryEvent());
    } catch (_) {}
  }

  void _navigateTo(BuildContext context, Widget page) {
    closeDrawerIfOpen(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _navigateHome(BuildContext context) {
    closeDrawerIfOpen(context);
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.popUntil((route) => route.isFirst);
    } else {
      nav.pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  Widget _navTile(BuildContext context, IconData icon, String title, Widget page,
      {VoidCallback? onTap}) {
    final cs = Theme.of(context).colorScheme;
    final bool isSelected = title == _activeRowTitle;
    return ListTile(
      dense: true,
      selected: isSelected,
      selectedTileColor: cs.primaryContainer.withValues(alpha: 0.65),
      leading: Icon(icon, size: 20, color: isSelected ? cs.primary : null),
      title: Text(title),
      onTap: onTap ?? () => _navigateTo(context, page),
    );
  }

  Widget _buildReminderTile(BuildContext context) {
    ReminderBloc? bloc;
    try {
      bloc = context.read<ReminderBloc>();
    } catch (_) {
      bloc = null;
    }
    if (bloc == null) {
      return _navTile(context, Icons.notifications, 'Bill Reminders', const RemindersPage());
    }
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, reminderState) {
        final unreadCount =
            reminderState is ReminderLoaded ? reminderState.unreadCount : 0;
        final bool isSelected = _activeRowTitle == 'Bill Reminders';
        return ListTile(
          dense: true,
          selected: isSelected,
          selectedTileColor: Theme.of(context)
              .colorScheme
              .primaryContainer
              .withValues(alpha: 0.65),
          leading: Stack(
            children: [
              Icon(
                Icons.notifications,
                size: 20,
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
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
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
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
          onTap: () => _navigateTo(context, const RemindersPage()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        _activeRowTitle = _resolveActiveRow(context);
        final sortedYears =
            state.availablePeriods.map((p) => p.year).toSet().toList()
              ..sort((a, b) => b.compareTo(a));

        return Drawer(
          elevation: 0,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primaryContainer,
                      cs.surfaceContainerHighest,
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            color: cs.primary,
                            size: 24,
                          ),
                        ),
                        if (widget.onToggleCollapse != null)
                          IconButton(
                            key: const ValueKey('sidebar_collapse_button'),
                            icon: Icon(
                              Icons.first_page_rounded,
                              color: cs.onPrimaryContainer,
                            ),
                            tooltip: 'Collapse Sidebar',
                            onPressed: widget.onToggleCollapse,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Budget App',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Executive Financial Workspace',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _navTile(
                context,
                Icons.space_dashboard_outlined,
                'Dashboard Overview',
                const HomePage(),
                onTap: () => _navigateHome(context),
              ),
              _navTile(context, Icons.pie_chart, 'Category Breakdown', const CategoryBreakdownPage()),
              _navTile(context, Icons.settings, 'Manage Categories', const CategorySettingsPage()),
              _navTile(context, Icons.trending_up, 'Projections', const ProjectionPage()),
              _navTile(context, Icons.autorenew, 'Recurring Transactions', const ManageRecurringPage()),
              _navTile(context, Icons.calculate, 'Financial Tools', const ToolsHubPage()),
              _navTile(context, Icons.account_balance_wallet, 'Accounts', const AccountsPage()),
              _navTile(context, Icons.savings, 'Savings Goals', const SavingsGoalsPage()),
              _buildReminderTile(context),
              _navTile(context, Icons.compare_arrows, 'Budget Comparison', const BudgetComparisonPage()),
              _navTile(context, Icons.calendar_month, 'Calendar View', const CalendarViewPage()),
              FeatureGate(
                flag: FeatureFlag.invoicingPayables,
                child: ExpansionTile(
                  leading: const Icon(Icons.business_center, size: 20),
                  title: const Text('Business Tools'),
                  children: [
                    _navTile(context, Icons.receipt_long, 'Invoices', const InvoicesPage()),
                    _navTile(context, Icons.people, 'Clients', const ClientsPage()),
                    _navTile(context, Icons.real_estate_agent_outlined, 'Loans', const LoansPage()),
                    _navTile(context, Icons.person, 'Business Profile', const ProfileSettingsPage()),
                  ],
                ),
              ),
              _navTile(context, Icons.settings_applications, 'App Settings', const SettingsPage()),
              const Divider(),
              ListTile(
                dense: true,
                leading: Icon(Icons.add_box_outlined, color: cs.primary, size: 20),
                title: Text('Create Budget', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
                onTap: () {
                  closeDrawerIfOpen(context);
                  showDialog(context: context, builder: (_) => const CreateBudgetDialog());
                },
              ),
              ListTile(
                dense: true,
                leading: Icon(Icons.add_circle_outline, color: cs.secondary, size: 20),
                title: Text(
                  'Create Disposable Budget',
                  style: TextStyle(color: cs.secondary, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  closeDrawerIfOpen(context);
                  showDialog(context: context, builder: (_) => const CreateDisposableDialog());
                },
              ),
              const Divider(),
              const NavigationDisposableSection(),
              ExpansionTile(
                leading: const Icon(Icons.layers_outlined, size: 20),
                title: const Text('Portfolio & Templates'),
                children: [
                  _navTile(context, Icons.credit_card, 'Credit Cards', const CreditCardsPage()),
                  _navTile(context, Icons.candlestick_chart_outlined, 'Investments', const InvestmentsPage()),
                  _navTile(context, Icons.real_estate_agent_outlined, 'Loans Tracker', const LoansPage()),
                  _navTile(context, Icons.copy_all_outlined, 'Budget Templates', const BudgetTemplatesPage()),
                  _navTile(context, Icons.playlist_add_check, 'Quick Add Templates', const RecurringTemplatesPage()),
                  _navTile(context, Icons.label_outline, 'Manage Tags', const TagsPage()),
                  _navTile(context, Icons.dashboard_customize_outlined, 'Dashboard Layout', const DashboardSettingsPage()),
                ],
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
                      onTap: () => setState(() => _expandedYears[year] = !isExpanded),
                    ),
                    if (isExpanded)
                      ...monthsInYear.map((period) {
                        Budget? sourceBudget;
                        for (final b in state.availableBudgetsForPeriod) {
                          if (b.periodMonth == period.month && b.periodYear == period.year) {
                            sourceBudget = b;
                            break;
                          }
                        }

                        return Dismissible(
                          key: ValueKey('period_${period.year}_${period.month}'),
                          direction: DismissDirection.horizontal,
                          background: Container(
                            color: cs.primary,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: Icon(Icons.copy, color: cs.onPrimary),
                          ),
                          secondaryBackground: Container(
                            color: cs.error,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: Icon(Icons.delete, color: cs.onError),
                          ),
                          confirmDismiss: (direction) async {
                            if (sourceBudget == null) return false;
                            if (direction == DismissDirection.startToEnd) {
                              return showCloneBudgetDialog(
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
                                  message:
                                      'Are you sure you want to delete "$budgetName"? All income and expense entries for this budget will also be deleted. This action cannot be undone.',
                                  confirmLabel: 'Delete',
                                  isDestructive: true,
                                  onConfirm: () => Navigator.pop(ctx, true),
                                ),
                              );
                              if (confirmed == true && context.mounted) {
                                context.read<BudgetBloc>().add(DeleteBudgetEvent(budgetId));
                              }
                              return confirmed == true;
                            }
                            return false;
                          },
                          child: ListTile(
                            dense: true,
                            title: Text(DateFormat('MMMM').format(DateTime(year, period.month))),
                            selected: state.currentPeriod == period,
                            onTap: () {
                              context.read<NavigationBloc>().add(ChangePeriod(period));
                              closeDrawerIfOpen(context);
                            },
                          ),
                        );
                      }),
                  ],
                );
              }),
              const Divider(),
              const PyCentricFooterWidget(compact: true),
            ],
          ),
        );
      },
    );
  }
}
