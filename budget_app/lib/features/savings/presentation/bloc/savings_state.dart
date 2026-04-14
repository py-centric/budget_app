import 'package:equatable/equatable.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/savings_contribution.dart';

abstract class SavingsState extends Equatable {
  const SavingsState();

  @override
  List<Object?> get props => [];
}

class SavingsInitial extends SavingsState {}

class SavingsLoading extends SavingsState {}

class SavingsLoaded extends SavingsState {
  final List<SavingsGoalWithContributions> goals;

  const SavingsLoaded(this.goals);

  double get totalSaved =>
      goals.fold(0, (sum, goal) => sum + goal.goal.currentAmount);

  double get totalTarget =>
      goals.fold(0, (sum, goal) => sum + goal.goal.targetAmount);

  @override
  List<Object?> get props => [goals];
}

class SavingsError extends SavingsState {
  final String message;

  const SavingsError(this.message);

  @override
  List<Object?> get props => [message];
}

class SavingsGoalWithContributions {
  final SavingsGoal goal;
  final List<SavingsContribution> contributions;

  const SavingsGoalWithContributions({
    required this.goal,
    required this.contributions,
  });

  double get totalContributions =>
      contributions.fold(0, (sum, c) => sum + c.amount);
}
