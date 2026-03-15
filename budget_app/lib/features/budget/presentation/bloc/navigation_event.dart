import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_period.dart';
import '../../domain/entities/budget.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object> get props => [];
}

class ChangePeriod extends NavigationEvent {
  final BudgetPeriod period;

  const ChangePeriod(this.period);

  @override
  List<Object> get props => [period];
}

class ChangeBudget extends NavigationEvent {
  final Budget budget;

  const ChangeBudget(this.budget);

  @override
  List<Object> get props => [budget];
}

class LoadAvailablePeriods extends NavigationEvent {
  const LoadAvailablePeriods();
}
