import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/core/feature_flags/models/feature_flag.dart';
import 'package:budget_app/core/feature_flags/presentation/widgets/feature_gate.dart';
import 'package:budget_app/features/accounts/presentation/pages/accounts_page.dart';
import 'package:budget_app/features/budget/presentation/pages/budget_comparison_page.dart';
import 'package:budget_app/features/budget/presentation/pages/category_breakdown_page.dart';
import 'package:budget_app/features/budget/presentation/pages/category_settings_page.dart';
import 'package:budget_app/features/budget/presentation/pages/home_page.dart';
import 'package:budget_app/features/budget/presentation/pages/manage_recurring_page.dart';
import 'package:budget_app/features/budget/presentation/pages/projection_page.dart';
import 'package:budget_app/features/business_tools/presentation/pages/invoices_page.dart';
import 'package:budget_app/features/calendar/presentation/pages/calendar_view_page.dart';
import 'package:budget_app/features/financial_tools/presentation/pages/tools_hub_page.dart';
import 'package:budget_app/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:budget_app/features/reminders/presentation/bloc/reminder_state.dart';
import 'package:budget_app/features/reminders/presentation/pages/reminders_page.dart';
import 'package:budget_app/features/savings/presentation/pages/savings_goals_page.dart';
import 'package:budget_app/features/settings/presentation/pages/settings_page.dart';
import 'create_budget_dialog.dart';
import 'create_disposable_dialog.dart';
import 'navigation_drawer_sections.dart';

/// Compact 72px icon rail rendered when the desktop sidebar is collapsed.
class CollapsedSidebarRail extends StatelessWidget {
  final VoidCallback? onExpand;
  final int? selectedIndex;

  const CollapsedSidebarRail({
    super.key,
    this.onExpand,
    this.selectedIndex,
  });

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

  Widget _railButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? iconColor,
    Widget? badge,
  }) {
    final cs = Theme.of(context).colorScheme;
    final effectiveColor =
        iconColor ?? (isSelected ? cs.primary : cs.onSurfaceVariant);

    Widget iconWidget = Icon(icon, size: 22, color: effectiveColor);
    if (badge != null) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(right: -4, top: -4, child: badge),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 250),
        child: Material(
          color: isSelected
              ? cs.primaryContainer.withValues(alpha: 0.65)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: SizedBox(
              height: 44,
              width: 52,
              child: Center(child: iconWidget),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderRailButton(BuildContext context) {
    ReminderBloc? bloc;
    try {
      bloc = context.read<ReminderBloc>();
    } catch (_) {
      bloc = null;
    }
    if (bloc == null) {
      return _railButton(
        context: context,
        icon: Icons.notifications_outlined,
        tooltip: 'Bill Reminders',
        onTap: () => _navigateTo(context, const RemindersPage()),
      );
    }
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        final unreadCount = state is ReminderLoaded ? state.unreadCount : 0;
        final cs = Theme.of(context).colorScheme;
        return _railButton(
          context: context,
          icon: Icons.notifications_outlined,
          tooltip: 'Bill Reminders',
          onTap: () => _navigateTo(context, const RemindersPage()),
          badge: unreadCount > 0
              ? Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: cs.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: TextStyle(
                      color: cs.onError,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cs.primaryContainer, cs.surfaceContainerHighest],
            ),
            border: Border(
              bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
          ),
          child: Column(
            children: [
              IconButton(
                key: const ValueKey('sidebar_expand_button'),
                icon: Icon(Icons.last_page_rounded, color: cs.primary),
                tooltip: 'Expand Sidebar',
                onPressed: onExpand,
              ),
              const SizedBox(height: 4),
              Tooltip(
                message: 'Budget App Home',
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _navigateHome(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: cs.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _railButton(
                context: context,
                icon: Icons.space_dashboard_outlined,
                tooltip: 'Dashboard Overview',
                isSelected: selectedIndex == 0,
                onTap: () => _navigateHome(context),
              ),
              _railButton(
                context: context,
                icon: Icons.pie_chart_outline,
                tooltip: 'Category Breakdown',
                isSelected: selectedIndex == 1,
                onTap: () => _navigateTo(context, const CategoryBreakdownPage()),
              ),
              _railButton(
                context: context,
                icon: Icons.settings_suggest_outlined,
                tooltip: 'Manage Categories',
                onTap: () => _navigateTo(context, const CategorySettingsPage()),
              ),
              _railButton(
                context: context,
                icon: Icons.trending_up,
                tooltip: 'Projections',
                onTap: () => _navigateTo(context, const ProjectionPage()),
              ),
              _railButton(
                context: context,
                icon: Icons.autorenew,
                tooltip: 'Recurring Transactions',
                onTap: () => _navigateTo(context, const ManageRecurringPage()),
              ),
              _railButton(
                context: context,
                icon: Icons.calculate_outlined,
                tooltip: 'Financial Tools',
                isSelected: selectedIndex == 3,
                onTap: () => _navigateTo(context, const ToolsHubPage()),
              ),
              _railButton(
                context: context,
                icon: Icons.account_balance_wallet_outlined,
                tooltip: 'Accounts',
                isSelected: selectedIndex == 2,
                onTap: () => _navigateTo(context, const AccountsPage()),
              ),
              _railButton(
                context: context,
                icon: Icons.savings_outlined,
                tooltip: 'Savings Goals',
                onTap: () => _navigateTo(context, const SavingsGoalsPage()),
              ),
              _buildReminderRailButton(context),
              _railButton(
                context: context,
                icon: Icons.compare_arrows,
                tooltip: 'Budget Comparison',
                onTap: () => _navigateTo(context, const BudgetComparisonPage()),
              ),
              _railButton(
                context: context,
                icon: Icons.calendar_month_outlined,
                tooltip: 'Calendar View',
                onTap: () => _navigateTo(context, const CalendarViewPage()),
              ),
              FeatureGate(
                flag: FeatureFlag.invoicingPayables,
                child: _railButton(
                  context: context,
                  icon: Icons.business_center_outlined,
                  tooltip: 'Business Invoices',
                  onTap: () => _navigateTo(context, const InvoicesPage()),
                ),
              ),
              _railButton(
                context: context,
                icon: Icons.settings_applications_outlined,
                tooltip: 'App Settings',
                isSelected: selectedIndex == 4,
                onTap: () => _navigateTo(context, const SettingsPage()),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Divider(height: 1),
              ),
              _railButton(
                context: context,
                icon: Icons.add_box_outlined,
                tooltip: 'Create Budget',
                iconColor: cs.primary,
                onTap: () {
                  closeDrawerIfOpen(context);
                  showDialog(
                    context: context,
                    builder: (_) => const CreateBudgetDialog(),
                  );
                },
              ),
              _railButton(
                context: context,
                icon: Icons.add_circle_outline,
                tooltip: 'Create Disposable Budget',
                iconColor: cs.secondary,
                onTap: () {
                  closeDrawerIfOpen(context);
                  showDialog(
                    context: context,
                    builder: (_) => const CreateDisposableDialog(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
