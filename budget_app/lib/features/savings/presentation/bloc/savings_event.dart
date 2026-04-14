import 'package:equatable/equatable.dart';
import '../../domain/entities/savings_goal.dart';

abstract class SavingsEvent extends Equatable {
  const SavingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavingsGoals extends SavingsEvent {}

class AddSavingsGoal extends SavingsEvent {
  final String name;
  final double targetAmount;
  final DateTime? deadline;
  final String? linkedCategoryId;
  final String? icon;
  final String? color;

  const AddSavingsGoal({
    required this.name,
    required this.targetAmount,
    this.deadline,
    this.linkedCategoryId,
    this.icon,
    this.color,
  });

  @override
  List<Object?> get props => [
    name,
    targetAmount,
    deadline,
    linkedCategoryId,
    icon,
    color,
  ];
}

class UpdateSavingsGoal extends SavingsEvent {
  final SavingsGoal goal;

  const UpdateSavingsGoal(this.goal);

  @override
  List<Object?> get props => [goal];
}

class DeleteSavingsGoal extends SavingsEvent {
  final String goalId;

  const DeleteSavingsGoal(this.goalId);

  @override
  List<Object?> get props => [goalId];
}

class AddContribution extends SavingsEvent {
  final String goalId;
  final double amount;
  final DateTime date;
  final String? note;

  const AddContribution({
    required this.goalId,
    required this.amount,
    required this.date,
    this.note,
  });

  @override
  List<Object?> get props => [goalId, amount, date, note];
}

class DeleteContribution extends SavingsEvent {
  final String contributionId;
  final String goalId;

  const DeleteContribution({
    required this.contributionId,
    required this.goalId,
  });

  @override
  List<Object?> get props => [contributionId, goalId];
}
