import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/core/theme/app_spacing.dart';
import '../../domain/entities/budget_comparison.dart';
import '../bloc/budget_comparison_bloc.dart';
import '../bloc/budget_comparison_event.dart';
import '../bloc/budget_comparison_state.dart';
import '../bloc/navigation_bloc.dart';
import '../widgets/budget_comparison_chart.dart';
import '../widgets/budget_comparison_table.dart';

class BudgetComparisonPage extends StatefulWidget {
  const BudgetComparisonPage({super.key});

  @override
  State<BudgetComparisonPage> createState() => _BudgetComparisonPageState();
}

class _BudgetComparisonPageState extends State<BudgetComparisonPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navState = context.read<NavigationBloc>().state;
      if (navState.activeBudget != null) {
        context.read<BudgetComparisonBloc>().add(
          LoadBudgetComparison(
            budgetId: navState.activeBudget!.id,
            year: navState.currentPeriod.year,
            month: navState.currentPeriod.month,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget vs Actual'), centerTitle: true),
      body: BlocBuilder<NavigationBloc, NavigationState>(
        builder: (context, navState) {
          if (navState.activeBudget == null) {
            return const Center(child: Text('No active budget selected'));
          }

          return BlocBuilder<BudgetComparisonBloc, BudgetComparisonState>(
            builder: (context, state) {
              if (state is BudgetComparisonLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is BudgetComparisonError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Error loading budget comparison',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          context.read<BudgetComparisonBloc>().add(
                            LoadBudgetComparison(
                              budgetId: navState.activeBudget!.id,
                              year: navState.currentPeriod.year,
                              month: navState.currentPeriod.month,
                            ),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is BudgetComparisonLoaded) {
                return _buildContent(context, state);
              }

              return _buildEmptyState(context, navState);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, NavigationState navState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare_arrows, size: 80, color: Theme.of(context).colorScheme.outline),
            SizedBox(height: AppSpacing.lg),
            Text(
              'No Budget Comparisons',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm + AppSpacing.xs),
            Text(
              'Set up category spending limits to see budget vs actual comparisons.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<BudgetComparisonBloc>().add(
                      LoadBudgetComparison(
                        budgetId: navState.activeBudget!.id,
                        year: navState.currentPeriod.year,
                        month: navState.currentPeriod.month,
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BudgetComparisonLoaded state) {
    final theme = Theme.of(context);

    if (state.comparisons.isEmpty) {
      return _buildEmptyState(context, context.read<NavigationBloc>().state);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<BudgetComparisonBloc>().add(RefreshBudgetComparison());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.xl - 4),
                    ),
                    child: Text(
                      '${_getMonthName(state.month)} ${state.year}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildStatusBadge(context, state.summary),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget vs Spending',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  BudgetComparisonChart(comparisons: state.comparisons),
                  SizedBox(height: AppSpacing.sm),
                  const BudgetComparisonLegend(),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'Category Breakdown',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: BudgetComparisonTable(
                comparisons: state.comparisons,
                summary: state.summary,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    BudgetComparisonSummary summary,
  ) {
    Color color;
    String text;
    IconData icon;

    if (summary.totalActual > summary.totalPlanned) {
      color = Theme.of(context).colorScheme.error;
      text = 'Over Budget';
      icon = Icons.warning;
    } else if (summary.totalActual < summary.totalPlanned * 0.8) {
      color = Theme.of(context).colorScheme.primary;
      text = 'Under Budget';
      icon = Icons.check_circle;
    } else {
      color = Theme.of(context).colorScheme.tertiary;
      text = 'On Track';
      icon = Icons.trending_flat;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
