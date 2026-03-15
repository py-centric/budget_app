import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../domain/entities/budget_period.dart';
import '../../domain/entities/budget.dart';
import '../../domain/usecases/get_available_periods.dart';
import '../../domain/repositories/budget_repository.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

export 'navigation_event.dart';
export 'navigation_state.dart';

class NavigationBloc extends HydratedBloc<NavigationEvent, NavigationState> {
  final GetAvailablePeriods getAvailablePeriodsUseCase;
  final BudgetRepository budgetRepository;

  NavigationBloc({
    required this.getAvailablePeriodsUseCase,
    required this.budgetRepository,
  }) : super(NavigationState(currentPeriod: BudgetPeriod.current())) {
    on<ChangePeriod>((event, emit) async {
      // Clear active budget when changing periods, it will be selected later
      emit(state.copyWith(currentPeriod: event.period, activeBudget: null));
      await _loadDefaultBudgetForPeriod(event.period, emit);
    });
    
    on<ChangeBudget>((event, emit) {
      emit(state.copyWith(activeBudget: event.budget));
    });
    
    on<LoadAvailablePeriods>((event, emit) async {
      final periods = await getAvailablePeriodsUseCase();
      emit(state.copyWith(availablePeriods: periods));
      if (state.activeBudget == null) {
        await _loadDefaultBudgetForPeriod(state.currentPeriod, emit);
      }
    });
  }

  Future<void> _loadDefaultBudgetForPeriod(BudgetPeriod period, Emitter<NavigationState> emit) async {
    var budgets = await budgetRepository.getBudgetsForPeriod(period);
    
    if (budgets.isEmpty) {
      // Create a default budget for the new period
      final defaultBudget = Budget(
        id: 'default_${period.year}_${period.month}',
        name: 'Main Budget',
        periodMonth: period.month,
        periodYear: period.year,
        isActive: true,
      );
      await budgetRepository.addBudget(defaultBudget);
      budgets = [defaultBudget];
      
      // Refresh available periods since we just added one for a potentially new period
      final periods = await getAvailablePeriodsUseCase();
      emit(state.copyWith(availablePeriods: periods));
    }

    // Try to find the active one, or just take the first
    final active = budgets.firstWhere((b) => b.isActive, orElse: () => budgets.first);
    emit(state.copyWith(
      activeBudget: active,
      availableBudgetsForPeriod: budgets,
    ));
  }

  @override
  NavigationState? fromJson(Map<String, dynamic> json) {
    try {
      return NavigationState.fromMap(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(NavigationState state) {
    return state.toMap();
  }
}
