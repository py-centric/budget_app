import 'package:budget_app/features/emergency_fund/domain/entities/emergency_expense.dart';

abstract class EmergencyFundRepository {
  Future<List<EmergencyExpense>> getExpenses();
  Future<void> saveExpense(EmergencyExpense expense);
  Future<void> deleteExpense(String id);
  Stream<double> watchTotalTarget();
  Future<double> getAverageMonthlySpending();
}
