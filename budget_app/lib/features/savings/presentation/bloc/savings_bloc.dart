import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/savings_contribution.dart';
import '../../domain/repositories/savings_repository.dart';
import 'savings_event.dart';
import 'savings_state.dart';

class SavingsBloc extends Bloc<SavingsEvent, SavingsState> {
  final SavingsRepository _repository;

  SavingsBloc({required SavingsRepository repository})
    : _repository = repository,
      super(SavingsInitial()) {
    on<LoadSavingsGoals>(_onLoadSavingsGoals);
    on<AddSavingsGoal>(_onAddSavingsGoal);
    on<UpdateSavingsGoal>(_onUpdateSavingsGoal);
    on<DeleteSavingsGoal>(_onDeleteSavingsGoal);
    on<AddContribution>(_onAddContribution);
    on<DeleteContribution>(_onDeleteContribution);
  }

  Future<void> _onLoadSavingsGoals(
    LoadSavingsGoals event,
    Emitter<SavingsState> emit,
  ) async {
    emit(SavingsLoading());
    try {
      final goals = await _repository.getAllGoals();
      final goalsWithContributions = <SavingsGoalWithContributions>[];

      for (final goal in goals) {
        final contributions = await _repository.getContributionsForGoal(
          goal.id,
        );
        goalsWithContributions.add(
          SavingsGoalWithContributions(
            goal: goal,
            contributions: contributions,
          ),
        );
      }

      emit(SavingsLoaded(goalsWithContributions));
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> _onAddSavingsGoal(
    AddSavingsGoal event,
    Emitter<SavingsState> emit,
  ) async {
    final now = DateTime.now();
    final goal = SavingsGoal(
      id: now.millisecondsSinceEpoch.toString(),
      name: event.name,
      targetAmount: event.targetAmount,
      currentAmount: 0,
      deadline: event.deadline,
      linkedCategoryId: event.linkedCategoryId,
      icon: event.icon,
      color: event.color,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.saveGoal(goal);
    add(LoadSavingsGoals());
  }

  Future<void> _onUpdateSavingsGoal(
    UpdateSavingsGoal event,
    Emitter<SavingsState> emit,
  ) async {
    final updatedGoal = event.goal.copyWith(updatedAt: DateTime.now());
    await _repository.saveGoal(updatedGoal);
    add(LoadSavingsGoals());
  }

  Future<void> _onDeleteSavingsGoal(
    DeleteSavingsGoal event,
    Emitter<SavingsState> emit,
  ) async {
    await _repository.deleteGoal(event.goalId);
    add(LoadSavingsGoals());
  }

  Future<void> _onAddContribution(
    AddContribution event,
    Emitter<SavingsState> emit,
  ) async {
    final contribution = SavingsContribution(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      goalId: event.goalId,
      amount: event.amount,
      date: event.date,
      note: event.note,
      createdAt: DateTime.now(),
    );

    await _repository.addContribution(contribution);

    final goal = await _repository.getGoalById(event.goalId);
    if (goal != null) {
      final updatedGoal = goal.copyWith(
        currentAmount: goal.currentAmount + event.amount,
        isCompleted: goal.currentAmount + event.amount >= goal.targetAmount,
        updatedAt: DateTime.now(),
      );
      await _repository.saveGoal(updatedGoal);
    }

    add(LoadSavingsGoals());
  }

  Future<void> _onDeleteContribution(
    DeleteContribution event,
    Emitter<SavingsState> emit,
  ) async {
    final contributions = await _repository.getContributionsForGoal(
      event.goalId,
    );
    final contribution = contributions.firstWhere(
      (c) => c.id == event.contributionId,
      orElse: () => throw Exception('Contribution not found'),
    );

    await _repository.deleteContribution(event.contributionId);

    final goal = await _repository.getGoalById(event.goalId);
    if (goal != null) {
      final updatedGoal = goal.copyWith(
        currentAmount: (goal.currentAmount - contribution.amount).clamp(
          0,
          double.infinity,
        ),
        isCompleted:
            (goal.currentAmount - contribution.amount) >= goal.targetAmount,
        updatedAt: DateTime.now(),
      );
      await _repository.saveGoal(updatedGoal);
    }

    add(LoadSavingsGoals());
  }
}
