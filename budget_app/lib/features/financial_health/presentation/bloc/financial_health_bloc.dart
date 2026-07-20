import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/calculate_financial_health.dart';
import 'financial_health_event.dart';
import 'financial_health_state.dart';

class FinancialHealthBloc extends Bloc<FinancialHealthEvent, FinancialHealthState> {
  final CalculateFinancialHealth _calculateHealth;

  FinancialHealthBloc({required CalculateFinancialHealth calculateHealth})
      : _calculateHealth = calculateHealth,
        super(const FinancialHealthInitial()) {
    on<CalculateHealthScore>(_onCalculateHealthScore);
  }

  Future<void> _onCalculateHealthScore(
    CalculateHealthScore event,
    Emitter<FinancialHealthState> emit,
  ) async {
    final score = await _calculateHealth(
      monthlyIncome: event.monthlyIncome,
      monthlyExpenses: event.monthlyExpenses,
      totalDebt: event.totalDebt,
      totalSavings: event.totalSavings,
    );
    emit(FinancialHealthLoaded(score));
  }
}
