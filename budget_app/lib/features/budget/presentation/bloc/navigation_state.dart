import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_period.dart';
import '../../domain/entities/budget.dart';

class NavigationState extends Equatable {
  final BudgetPeriod currentPeriod;
  final List<BudgetPeriod> availablePeriods;
  final Budget? activeBudget;
  final List<Budget> availableBudgetsForPeriod;

  const NavigationState({
    required this.currentPeriod,
    this.availablePeriods = const [],
    this.activeBudget,
    this.availableBudgetsForPeriod = const [],
  });

  NavigationState copyWith({
    BudgetPeriod? currentPeriod,
    List<BudgetPeriod>? availablePeriods,
    Budget? activeBudget,
    List<Budget>? availableBudgetsForPeriod,
  }) {
    return NavigationState(
      currentPeriod: currentPeriod ?? this.currentPeriod,
      availablePeriods: availablePeriods ?? this.availablePeriods,
      activeBudget: activeBudget ?? this.activeBudget,
      availableBudgetsForPeriod: availableBudgetsForPeriod ?? this.availableBudgetsForPeriod,
    );
  }

  @override
  List<Object?> get props => [currentPeriod, availablePeriods, activeBudget, availableBudgetsForPeriod];

  Map<String, dynamic> toMap() {
    return {
      'year': currentPeriod.year,
      'month': currentPeriod.month,
      // We don't persist activeBudget yet, or we could persist its ID
    };
  }

  factory NavigationState.fromMap(Map<String, dynamic> map) {
    return NavigationState(
      currentPeriod: BudgetPeriod(
        year: map['year'] as int,
        month: map['month'] as int,
      ),
    );
  }
}
