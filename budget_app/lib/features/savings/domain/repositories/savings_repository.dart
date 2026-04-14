import '../entities/savings_goal.dart';
import '../entities/savings_contribution.dart';

abstract class SavingsRepository {
  Future<List<SavingsGoal>> getAllGoals();
  Future<SavingsGoal?> getGoalById(String id);
  Future<void> saveGoal(SavingsGoal goal);
  Future<void> deleteGoal(String id);
  Future<void> addContribution(SavingsContribution contribution);
  Future<List<SavingsContribution>> getContributionsForGoal(String goalId);
  Future<void> deleteContribution(String id);
}
