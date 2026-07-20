import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_template.dart';

abstract class BudgetTemplatesState extends Equatable {
  const BudgetTemplatesState();
  @override
  List<Object?> get props => [];
}

class BudgetTemplatesInitial extends BudgetTemplatesState {
  const BudgetTemplatesInitial();
}

class BudgetTemplatesLoading extends BudgetTemplatesState {
  const BudgetTemplatesLoading();
}

class BudgetTemplatesLoaded extends BudgetTemplatesState {
  final List<BudgetTemplate> templates;
  const BudgetTemplatesLoaded(this.templates);
  @override
  List<Object?> get props => [templates];
}

class TemplateApplied extends BudgetTemplatesState {
  final Map<String, double> categoryAmounts;
  const TemplateApplied(this.categoryAmounts);
  @override
  List<Object?> get props => [categoryAmounts];
}

class BudgetTemplatesError extends BudgetTemplatesState {
  final String message;
  const BudgetTemplatesError(this.message);
  @override
  List<Object?> get props => [message];
}
