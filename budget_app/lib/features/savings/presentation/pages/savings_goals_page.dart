import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/core/theme/app_spacing.dart';
import 'package:budget_app/core/utils/currency_formatter.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:budget_app/shared/widgets/confirm_action_dialog.dart';
import '../bloc/savings_bloc.dart';
import '../bloc/savings_event.dart';
import '../bloc/savings_state.dart';
import '../widgets/savings_goal_card.dart';
import '../widgets/savings_goal_dialog.dart';
import '../widgets/add_contribution_dialog.dart';
import '../widgets/savings_calculator_dialog.dart';
import 'package:budget_app/shared/widgets/branding_footer.dart';

class SavingsGoalsPage extends StatelessWidget {
  const SavingsGoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            tooltip: 'Savings Calculator',
            onPressed: () => _showCalculatorDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<SavingsBloc, SavingsState>(
        builder: (context, state) {
          if (state is SavingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SavingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading savings goals',
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
                      context.read<SavingsBloc>().add(LoadSavingsGoals());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is SavingsLoaded) {
            if (state.goals.isEmpty) {
              return _buildEmptyState(context);
            }

            return _buildGoalsList(context, state);
          }

          return _buildEmptyState(context);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.savings_outlined, size: 80, color: Theme.of(context).colorScheme.outline),
            SizedBox(height: AppSpacing.lg),
            Text(
              'No Savings Goals Yet',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm + AppSpacing.xs),
            Text(
              'Start saving for your dreams! Create a goal to track your progress.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () => _showAddGoalDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Goal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsList(BuildContext context, SavingsLoaded state) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildSummaryHeader(context, state)),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final goalWithContributions = state.goals[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: SavingsGoalCard(
                goalWithContributions: goalWithContributions,
                onEdit: () =>
                    _showEditGoalDialog(context, goalWithContributions.goal),
                onDelete: () => _showDeleteConfirmation(
                  context,
                  goalWithContributions.goal,
                ),
                onAddContribution: () => _showAddContributionDialog(
                  context,
                  goalWithContributions.goal,
                ),
              ),
            );
          }, childCount: state.goals.length),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
        const SliverToBoxAdapter(child: BrandingFooter()),
      ],
    );
  }

  Widget _buildSummaryHeader(BuildContext context, SavingsLoaded state) {
    final theme = Theme.of(context);
    final totalSaved = state.totalSaved;
    final totalTarget = state.totalTarget;
    final currencyCode = context
        .read<SettingsBloc>()
        .state
        .settings
        .currencyCode;
    final overallProgress = totalTarget > 0
        ? (totalSaved / totalTarget * 100)
        : 0.0;

    final onPrimary = theme.colorScheme.onPrimary;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Saved',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: onPrimary.withValues(alpha: 0.9),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + AppSpacing.xs,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${overallProgress.toStringAsFixed(0)}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            CurrencyFormatter.format(totalSaved, currencyCode: currencyCode),
            style: theme.textTheme.headlineLarge?.copyWith(
              color: onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'of ${CurrencyFormatter.format(totalTarget, currencyCode: currencyCode)} total goal',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: onPrimary.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: LinearProgressIndicator(
              value: totalTarget > 0
                  ? (totalSaved / totalTarget).clamp(0, 1)
                  : 0,
              backgroundColor: onPrimary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(onPrimary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  void _showCalculatorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const SavingsCalculatorDialog(),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => SavingsGoalDialog(
        onSave: (name, targetAmount, deadline, linkedCategoryId, icon, color) {
          context.read<SavingsBloc>().add(
            AddSavingsGoal(
              name: name,
              targetAmount: targetAmount,
              deadline: deadline,
              linkedCategoryId: linkedCategoryId,
              icon: icon,
              color: color,
            ),
          );
        },
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, goal) {
    showDialog(
      context: context,
      builder: (dialogContext) => SavingsGoalDialog(
        existingGoal: goal,
        onSave: (name, targetAmount, deadline, linkedCategoryId, icon, color) {
          context.read<SavingsBloc>().add(
            UpdateSavingsGoal(
              goal.copyWith(
                name: name,
                targetAmount: targetAmount,
                deadline: deadline,
                linkedCategoryId: linkedCategoryId,
                icon: icon,
                color: color,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, goal) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmActionDialog(
        title: 'Delete Goal?',
        message: 'Are you sure you want to delete "${goal.name}"? This action cannot be undone.',
        confirmLabel: 'Delete',
        isDestructive: true,
        onConfirm: () {
          context.read<SavingsBloc>().add(DeleteSavingsGoal(goal.id));
        },
      ),
    );
  }

  void _showAddContributionDialog(BuildContext context, goal) {
    showDialog(
      context: context,
      builder: (dialogContext) => AddContributionDialog(
        goal: goal,
        onAdd: (amount, date, note) {
          context.read<SavingsBloc>().add(
            AddContribution(
              goalId: goal.id,
              amount: amount,
              date: date,
              note: note,
            ),
          );
        },
      ),
    );
  }
}
