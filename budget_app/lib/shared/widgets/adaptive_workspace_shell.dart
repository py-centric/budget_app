import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/features/accounts/presentation/pages/accounts_page.dart';
import 'package:budget_app/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:budget_app/features/budget/presentation/bloc/navigation_bloc.dart';
import 'package:budget_app/features/budget/presentation/pages/category_breakdown_page.dart';
import 'package:budget_app/features/budget/presentation/pages/home_page.dart';
import 'package:budget_app/features/budget/presentation/widgets/collapsed_sidebar_rail.dart';
import 'package:budget_app/features/budget/presentation/widgets/navigation_drawer_widget.dart';
import 'package:budget_app/features/financial_tools/presentation/pages/tools_hub_page.dart';
import 'package:budget_app/features/settings/presentation/pages/settings_page.dart';
import 'package:budget_app/shared/widgets/workspace_destination.dart';

enum WorkspaceTier {
  compact, // < 600dp
  medium, // 600dp - 839dp
  expanded, // 840dp - 1199dp
  ultraWide, // >= 1200dp
}

/// 4-Tier Adaptive M3 Workspace Shell supporting Compact (<600dp),
/// Medium (600-839dp), Expanded (840-1199dp), and Ultra-Wide (>=1200dp)
/// viewports while guaranteeing a persistent collapsible sidebar/navbar and
/// a reliable back button across every page in the application.
class AdaptiveWorkspaceShell extends StatelessWidget {
  /// Global reactive state for the desktop collapsible sidebar so the user's
  /// collapsed/expanded preference persists smoothly across page navigation.
  static final ValueNotifier<bool> isSidebarCollapsed =
      ValueNotifier<bool>(false);

  /// Toggles the desktop sidebar between expanded (296px) and collapsed (72px).
  static void toggleSidebar() {
    isSidebarCollapsed.value = !isSidebarCollapsed.value;
  }

  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool isHomePage;
  final int selectedIndex;

  const AdaptiveWorkspaceShell({
    super.key,
    this.appBar,
    this.drawer,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.isHomePage = false,
    required this.selectedIndex,
  });

  static WorkspaceTier tierOf(double width) {
    if (width >= 1200) return WorkspaceTier.ultraWide;
    if (width >= 840) return WorkspaceTier.expanded;
    if (width >= 600) return WorkspaceTier.medium;
    return WorkspaceTier.compact;
  }

  static bool isDockedTier(WorkspaceTier tier) =>
      tier == WorkspaceTier.ultraWide || tier == WorkspaceTier.expanded;

  bool _hasShellContext(BuildContext context) {
    try {
      context.read<NavigationBloc>();
      context.read<BudgetBloc>();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _handleBack(BuildContext context) {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else if (_hasShellContext(context)) {
      nav.pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  void _onDestinationSelected(
    BuildContext context,
    int index, {
    required int activeIndex,
  }) {
    if (index == activeIndex) return;
    final nav = Navigator.of(context);
    if (index == 0) {
      if (nav.canPop()) {
        nav.popUntil((route) => route.isFirst);
      } else {
        nav.pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      }
      return;
    }
    final Widget destination = switch (index) {
      1 => const CategoryBreakdownPage(),
      2 => const AccountsPage(),
      3 => const ToolsHubPage(),
      4 => const SettingsPage(),
      _ => const HomePage(),
    };
    nav.push(MaterialPageRoute(builder: (_) => destination));
  }

  PreferredSizeWidget? _buildEffectiveAppBar({
    required BuildContext context,
    required WorkspaceTier tier,
    required bool hasShell,
    required bool hasSidebar,
    required bool isCollapsed,
  }) {
    final raw = appBar;
    if (raw is! AppBar) {
      return raw;
    }

    final docked = isDockedTier(tier) && hasSidebar;

    if (isHomePage) {
      if (!docked) {
        return raw;
      }
      final homeLeading = raw.leading ??
          IconButton(
            key: const ValueKey('appbar_sidebar_toggle'),
            icon: Icon(
              isCollapsed ? Icons.menu_rounded : Icons.menu_open_rounded,
            ),
            tooltip: isCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar',
            onPressed: toggleSidebar,
          );
      return _copyAppBar(raw, leading: homeLeading, actions: raw.actions);
    }

    final leading = raw.leading ??
        BackButton(
          onPressed: () => _handleBack(context),
        );

    final actions = <Widget>[
      if (raw.actions != null) ...raw.actions!,
      if (docked)
        IconButton(
          key: const ValueKey('appbar_sidebar_toggle'),
          icon: Icon(
            isCollapsed ? Icons.dock_rounded : Icons.menu_open_rounded,
          ),
          tooltip: isCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar',
          onPressed: toggleSidebar,
        )
      else if (hasShell)
        Builder(
          builder: (btnCtx) => IconButton(
            icon: const Icon(Icons.menu_open_rounded),
            tooltip: 'Open Navigation Menu',
            onPressed: () => Scaffold.maybeOf(btnCtx)?.openDrawer(),
          ),
        ),
    ];

    return _copyAppBar(raw, leading: leading, actions: actions);
  }

  AppBar _copyAppBar(
    AppBar raw, {
    required Widget? leading,
    required List<Widget>? actions,
  }) {
    return AppBar(
      key: raw.key,
      leading: leading,
      automaticallyImplyLeading: raw.automaticallyImplyLeading,
      title: raw.title,
      actions: actions,
      flexibleSpace: raw.flexibleSpace,
      bottom: raw.bottom,
      elevation: raw.elevation,
      scrolledUnderElevation: raw.scrolledUnderElevation,
      notificationPredicate: raw.notificationPredicate,
      shadowColor: raw.shadowColor,
      surfaceTintColor: raw.surfaceTintColor,
      shape: raw.shape,
      backgroundColor: raw.backgroundColor,
      foregroundColor: raw.foregroundColor,
      iconTheme: raw.iconTheme,
      actionsIconTheme: raw.actionsIconTheme,
      primary: raw.primary,
      centerTitle: raw.centerTitle,
      excludeHeaderSemantics: raw.excludeHeaderSemantics,
      titleSpacing: raw.titleSpacing,
      toolbarOpacity: raw.toolbarOpacity,
      bottomOpacity: raw.bottomOpacity,
      toolbarHeight: raw.toolbarHeight,
      leadingWidth: raw.leadingWidth,
      toolbarTextStyle: raw.toolbarTextStyle,
      titleTextStyle: raw.titleTextStyle,
      systemOverlayStyle: raw.systemOverlayStyle,
      forceMaterialTransparency: raw.forceMaterialTransparency,
      clipBehavior: raw.clipBehavior,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasShell = _hasShellContext(context);
    // Every adopting page declares its workspace destination explicitly, so
    // the navbar, collapsed rail and drawer chrome all highlight the screen
    // the user is actually on (compile-enforced by the required parameter).
    final activeIndex = selectedIndex;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tier = tierOf(constraints.maxWidth);
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final hasSidebar = drawer != null || hasShell;

        if (isDockedTier(tier) && hasSidebar) {
          return ValueListenableBuilder<bool>(
            valueListenable: isSidebarCollapsed,
            builder: (context, isCollapsed, _) {
              final effectiveAppBar = _buildEffectiveAppBar(
                context: context,
                tier: tier,
                hasShell: hasShell,
                hasSidebar: hasSidebar,
                isCollapsed: isCollapsed,
              );

              final Widget dockedSidebarChild;
              if (isCollapsed) {
                dockedSidebarChild = CollapsedSidebarRail(
                  onExpand: toggleSidebar,
                  selectedIndex: activeIndex,
                );
              } else if (drawer == null || drawer is NavigationDrawerWidget) {
                dockedSidebarChild = NavigationDrawerWidget(
                  onToggleCollapse: toggleSidebar,
                  activeDestination:
                      WorkspaceDestination.fromShellIndex(activeIndex),
                );
              } else {
                dockedSidebarChild = drawer!;
              }

              final sidebarWidth = isCollapsed ? 72.0 : 296.0;

              return Scaffold(
                appBar: effectiveAppBar,
                floatingActionButton: floatingActionButton,
                floatingActionButtonLocation: floatingActionButtonLocation,
                bottomNavigationBar: bottomNavigationBar,
                body: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedContainer(
                      key: const ValueKey('docked_collapsible_sidebar'),
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      width: sidebarWidth,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        border: Border(
                          right: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      child: OverflowBox(
                        alignment: Alignment.topLeft,
                        minWidth: sidebarWidth,
                        maxWidth: sidebarWidth,
                        child: dockedSidebarChild,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: tier == WorkspaceTier.ultraWide
                                ? 1440
                                : 1160,
                          ),
                          child: body,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        final modalDrawer =
            drawer ??
            (hasShell
                ? NavigationDrawerWidget(
                    activeDestination:
                        WorkspaceDestination.fromShellIndex(activeIndex),
                  )
                : null);
        final effectiveAppBar = _buildEffectiveAppBar(
          context: context,
          tier: tier,
          hasShell: hasShell,
          hasSidebar: hasSidebar,
          isCollapsed: false,
        );

        // selectedIndex is required since destination tracking was made
        // compile-enforced, so every shell instance carries an index and the
        // compact navbar is shown unless the page supplies its own bottom bar.
        final showBottomBar =
            tier == WorkspaceTier.compact &&
            bottomNavigationBar == null &&
            floatingActionButton == null;

        return Scaffold(
          appBar: effectiveAppBar,
          drawer: modalDrawer,
          body: body,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          bottomNavigationBar:
              bottomNavigationBar ??
              (showBottomBar
                  ? NavigationBar(
                      selectedIndex: activeIndex.clamp(0, 4),
                      onDestinationSelected: (idx) => _onDestinationSelected(
                        context,
                        idx,
                        activeIndex: activeIndex,
                      ),
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.space_dashboard_outlined),
                          selectedIcon: Icon(Icons.space_dashboard),
                          label: 'Overview',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.donut_large_outlined),
                          selectedIcon: Icon(Icons.donut_large),
                          label: 'Breakdown',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.account_balance_wallet_outlined),
                          selectedIcon: Icon(Icons.account_balance_wallet),
                          label: 'Wallet',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.calculate_outlined),
                          selectedIcon: Icon(Icons.calculate),
                          label: 'Tools',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.tune_outlined),
                          selectedIcon: Icon(Icons.tune),
                          label: 'Preferences',
                        ),
                      ],
                    )
                  : null),
        );
      },
    );
  }
}
