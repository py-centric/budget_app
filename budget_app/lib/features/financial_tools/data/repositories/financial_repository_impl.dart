import '../../../budget/data/datasources/local_database.dart';
import '../../domain/entities/saved_calculation.dart';
import '../../domain/repositories/financial_repository.dart';
import '../models/saved_calculation_model.dart';

class FinancialRepositoryImpl implements FinancialRepository {
  final LocalDatabase _localDatabase;

  FinancialRepositoryImpl(this._localDatabase);

  @override
  Future<void> saveCalculation(SavedCalculation calculation) async {
    final model = SavedCalculationModel.fromEntity(calculation);
    await _localDatabase.insertSavedCalculation(model.toMap());
  }

  @override
  Future<List<SavedCalculation>> getSavedCalculations() async {
    final maps = await _localDatabase.getSavedCalculations();
    return maps.map<SavedCalculation>((map) => SavedCalculationModel.fromMap(map)).toList();
  }

  @override
  Future<void> deleteCalculation(String id) async {
    await _localDatabase.deleteSavedCalculation(id);
  }
}
