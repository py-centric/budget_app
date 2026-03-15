import 'dart:async';
import 'package:budget_app/features/emergency_fund/domain/entities/emergency_expense.dart';
import 'package:budget_app/features/emergency_fund/domain/repositories/emergency_fund_repository.dart';
import 'package:budget_app/features/budget/data/datasources/local_database.dart';
import 'package:budget_app/features/emergency_fund/data/models/emergency_expense_model.dart';

class EmergencyFundRepositoryImpl implements EmergencyFundRepository {
  final LocalDatabase _localDatabase;
  final _totalTargetController = StreamController<double>.broadcast();

  EmergencyFundRepositoryImpl(this._localDatabase);

  @override
  Future<List<EmergencyExpense>> getExpenses() async {
    final maps = await _localDatabase.getEmergencyExpenses();
    final expenses = maps.map((map) => EmergencyExpenseModel.fromMap(map)).toList();
    _updateTotalTarget(expenses);
    return expenses;
  }

  @override
  Future<void> saveExpense(EmergencyExpense expense) async {
    final model = EmergencyExpenseModel.fromEntity(expense);
    final existing = await _localDatabase.getEmergencyExpenses();
    if (existing.any((e) => e['id'] == model.id)) {
      await _localDatabase.updateEmergencyExpense(model.toMap());
    } else {
      await _localDatabase.insertEmergencyExpense(model.toMap());
    }
    await getExpenses(); // This will refresh and update stream
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _localDatabase.deleteEmergencyExpense(id);
    await getExpenses(); // This will refresh and update stream
  }

  @override
  Stream<double> watchTotalTarget() {
    // Initial load from metadata or calculation
    _loadInitialTotalTarget();
    return _totalTargetController.stream;
  }

  Future<void> _loadInitialTotalTarget() async {
    final persisted = await _localDatabase.getMetadata('emergency_fund_target');
    if (persisted != null) {
      _totalTargetController.add(double.tryParse(persisted) ?? 0.0);
    } else {
      await getExpenses(); // This will calculate and update
    }
  }

  @override
  Future<double> getAverageMonthlySpending() async {
    return await _localDatabase.getAverageSpendingForLastMonths(3);
  }

  void _updateTotalTarget(List<EmergencyExpense> expenses) async {
    final total = expenses.fold<double>(0, (sum, item) => sum + item.amount);
    _totalTargetController.add(total);
    await _localDatabase.setMetadata('emergency_fund_target', total.toString());
  }
}
