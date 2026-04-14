import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/budget_comparison.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../domain/repositories/category_limit_repository.dart';
import 'budget_comparison_event.dart';
import 'budget_comparison_state.dart';

class BudgetComparisonBloc
    extends Bloc<BudgetComparisonEvent, BudgetComparisonState> {
  final BudgetRepository _budgetRepository;
  final CategoryLimitRepository _categoryLimitRepository;

  String? _currentBudgetId;
  int? _currentYear;
  int? _currentMonth;

  BudgetComparisonBloc({
    required BudgetRepository budgetRepository,
    required CategoryLimitRepository categoryLimitRepository,
  }) : _budgetRepository = budgetRepository,
       _categoryLimitRepository = categoryLimitRepository,
       super(BudgetComparisonInitial()) {
    on<LoadBudgetComparison>(_onLoadBudgetComparison);
    on<RefreshBudgetComparison>(_onRefreshBudgetComparison);
  }

  Future<void> _onLoadBudgetComparison(
    LoadBudgetComparison event,
    Emitter<BudgetComparisonState> emit,
  ) async {
    emit(BudgetComparisonLoading());
    try {
      _currentBudgetId = event.budgetId;
      _currentYear = event.year;
      _currentMonth = event.month;

      final comparisons = await _calculateComparisons(
        event.budgetId,
        event.year,
        event.month,
      );

      final summary = _calculateSummary(comparisons);

      emit(
        BudgetComparisonLoaded(
          comparisons: comparisons,
          summary: summary,
          year: event.year,
          month: event.month,
        ),
      );
    } catch (e) {
      emit(BudgetComparisonError(e.toString()));
    }
  }

  Future<void> _onRefreshBudgetComparison(
    RefreshBudgetComparison event,
    Emitter<BudgetComparisonState> emit,
  ) async {
    if (_currentBudgetId != null &&
        _currentYear != null &&
        _currentMonth != null) {
      add(
        LoadBudgetComparison(
          budgetId: _currentBudgetId!,
          year: _currentYear!,
          month: _currentMonth!,
        ),
      );
    }
  }

  Future<List<BudgetComparison>> _calculateComparisons(
    String budgetId,
    int year,
    int month,
  ) async {
    final limits = await _categoryLimitRepository.getLimitsForBudget(budgetId);
    final categories = await _budgetRepository.getCategories();
    final comparisons = <BudgetComparison>[];

    for (final limit in limits) {
      final spent = await _categoryLimitRepository.getSpentAmountForCategory(
        limit.categoryId,
        year,
        month,
      );

      final category = categories.firstWhere(
        (c) => c.id == limit.categoryId,
        orElse: () =>
            throw Exception('Category not found: ${limit.categoryId}'),
      );

      comparisons.add(
        BudgetComparison(
          categoryId: limit.categoryId,
          categoryName: category.name,
          categoryIcon: category.icon,
          plannedAmount: limit.amount,
          actualAmount: spent,
          year: year,
          month: month,
        ),
      );
    }

    comparisons.sort(
      (a, b) =>
          b.variancePercentage.abs().compareTo(a.variancePercentage.abs()),
    );

    return comparisons;
  }

  BudgetComparisonSummary _calculateSummary(
    List<BudgetComparison> comparisons,
  ) {
    final totalPlanned = comparisons.fold<double>(
      0,
      (sum, c) => sum + c.plannedAmount,
    );

    final totalActual = comparisons.fold<double>(
      0,
      (sum, c) => sum + c.actualAmount,
    );

    int overBudgetCount = 0;
    int underBudgetCount = 0;
    int onTrackCount = 0;

    for (final comparison in comparisons) {
      if (comparison.isOverBudget) {
        overBudgetCount++;
      } else if (comparison.isOnTrack) {
        onTrackCount++;
      } else {
        underBudgetCount++;
      }
    }

    return BudgetComparisonSummary(
      totalPlanned: totalPlanned,
      totalActual: totalActual,
      totalVariance: totalPlanned - totalActual,
      overBudgetCount: overBudgetCount,
      underBudgetCount: underBudgetCount,
      onTrackCount: onTrackCount,
    );
  }
}
