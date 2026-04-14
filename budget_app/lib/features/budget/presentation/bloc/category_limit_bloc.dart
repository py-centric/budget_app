import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category_limit.dart';
import '../../domain/repositories/category_limit_repository.dart';
import '../../domain/repositories/budget_repository.dart';
import 'category_limit_event.dart';
import 'category_limit_state.dart';

class CategoryLimitBloc extends Bloc<CategoryLimitEvent, CategoryLimitState> {
  final CategoryLimitRepository _repository;
  final BudgetRepository _budgetRepository;

  String? _currentBudgetId;
  int? _currentYear;
  int? _currentMonth;

  CategoryLimitBloc({
    required CategoryLimitRepository repository,
    required BudgetRepository budgetRepository,
  }) : _repository = repository,
       _budgetRepository = budgetRepository,
       super(CategoryLimitInitial()) {
    on<LoadCategoryLimits>(_onLoadCategoryLimits);
    on<AddCategoryLimit>(_onAddCategoryLimit);
    on<UpdateCategoryLimit>(_onUpdateCategoryLimit);
    on<DeleteCategoryLimit>(_onDeleteCategoryLimit);
  }

  Future<void> _onLoadCategoryLimits(
    LoadCategoryLimits event,
    Emitter<CategoryLimitState> emit,
  ) async {
    emit(CategoryLimitLoading());
    try {
      _currentBudgetId = event.budgetId;
      _currentYear = event.year;
      _currentMonth = event.month;

      final limits = await _repository.getLimitsForBudget(event.budgetId);
      final categories = await _budgetRepository.getCategories();
      final limitsWithSpending = <CategoryLimitWithSpending>[];

      for (final limit in limits) {
        final spent = await _repository.getSpentAmountForCategory(
          limit.categoryId,
          event.year,
          event.month,
        );

        final category = categories.firstWhere(
          (c) => c.id == limit.categoryId,
          orElse: () =>
              throw Exception('Category not found: ${limit.categoryId}'),
        );

        limitsWithSpending.add(
          CategoryLimitWithSpending(
            limit: limit,
            spentAmount: spent,
            categoryName: category.name,
            categoryIcon: category.icon,
          ),
        );
      }

      emit(
        CategoryLimitLoaded(
          limits: limitsWithSpending,
          year: event.year,
          month: event.month,
        ),
      );
    } catch (e) {
      emit(CategoryLimitError(e.toString()));
    }
  }

  Future<void> _onAddCategoryLimit(
    AddCategoryLimit event,
    Emitter<CategoryLimitState> emit,
  ) async {
    final now = DateTime.now();

    final limit = CategoryLimit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categoryId: event.categoryId,
      amount: event.amount,
      period: event.period,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.saveLimit(limit, event.budgetId);

    if (_currentBudgetId != null &&
        _currentYear != null &&
        _currentMonth != null) {
      add(
        LoadCategoryLimits(
          budgetId: _currentBudgetId!,
          year: _currentYear!,
          month: _currentMonth!,
        ),
      );
    }
  }

  Future<void> _onUpdateCategoryLimit(
    UpdateCategoryLimit event,
    Emitter<CategoryLimitState> emit,
  ) async {
    final updatedLimit = event.limit.copyWith(updatedAt: DateTime.now());
    await _repository.saveLimit(updatedLimit, event.limit.categoryId);

    if (_currentBudgetId != null &&
        _currentYear != null &&
        _currentMonth != null) {
      add(
        LoadCategoryLimits(
          budgetId: _currentBudgetId!,
          year: _currentYear!,
          month: _currentMonth!,
        ),
      );
    }
  }

  Future<void> _onDeleteCategoryLimit(
    DeleteCategoryLimit event,
    Emitter<CategoryLimitState> emit,
  ) async {
    await _repository.deleteLimit(event.limitId);

    if (_currentBudgetId != null &&
        _currentYear != null &&
        _currentMonth != null) {
      add(
        LoadCategoryLimits(
          budgetId: _currentBudgetId!,
          year: _currentYear!,
          month: _currentMonth!,
        ),
      );
    }
  }
}
