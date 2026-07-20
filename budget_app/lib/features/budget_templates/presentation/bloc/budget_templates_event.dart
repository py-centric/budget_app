import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_template.dart';

abstract class BudgetTemplatesEvent extends Equatable {
  const BudgetTemplatesEvent();
  @override
  List<Object?> get props => [];
}

class LoadAllTemplates extends BudgetTemplatesEvent {
  const LoadAllTemplates();
}

class CreateTemplateEvent extends BudgetTemplatesEvent {
  final String name;
  final String? description;
  final List<TemplateAllocation> allocations;
  const CreateTemplateEvent({required this.name, this.description, this.allocations = const []});
  @override
  List<Object?> get props => [name, description, allocations];
}

class UpdateTemplateEvent extends BudgetTemplatesEvent {
  final BudgetTemplate template;
  final List<TemplateAllocation> allocations;
  const UpdateTemplateEvent({required this.template, this.allocations = const []});
  @override
  List<Object?> get props => [template, allocations];
}

class DeleteTemplateEvent extends BudgetTemplatesEvent {
  final String templateId;
  const DeleteTemplateEvent(this.templateId);
  @override
  List<Object?> get props => [templateId];
}

class ApplyTemplateEvent extends BudgetTemplatesEvent {
  final String templateId;
  final double totalBudget;
  const ApplyTemplateEvent({required this.templateId, required this.totalBudget});
  @override
  List<Object?> get props => [templateId, totalBudget];
}
