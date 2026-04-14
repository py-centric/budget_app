import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/savings_bloc.dart';
import '../bloc/savings_event.dart';
import '../bloc/savings_state.dart';
import '../widgets/savings_goal_card.dart';
import '../widgets/savings_goal_dialog.dart';
import '../widgets/add_contribution_dialog.dart';

class SavingsGoalsPage extends StatelessWidget {
  const SavingsGoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goals'), centerTitle: true),
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
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.savings_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No Savings Goals Yet',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Start saving for your dreams! Create a goal to track your progress.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
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
              padding: const EdgeInsets.only(bottom: 8),
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
      ],
    );
  }

  Widget _buildSummaryHeader(BuildContext context, SavingsLoaded state) {
    final theme = Theme.of(context);
    final totalSaved = state.totalSaved;
    final totalTarget = state.totalTarget;
    final overallProgress = totalTarget > 0
        ? (totalSaved / totalTarget * 100)
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
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
        borderRadius: BorderRadius.circular(16),
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
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${overallProgress.toStringAsFixed(0)}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${totalSaved.toStringAsFixed(2)}',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'of \$${totalTarget.toStringAsFixed(2)} total goal',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalTarget > 0
                  ? (totalSaved / totalTarget).clamp(0, 1)
                  : 0,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Goal?'),
        content: Text(
          'Are you sure you want to delete "${goal.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<SavingsBloc>().add(DeleteSavingsGoal(goal.id));
              Navigator.of(dialogContext).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
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
