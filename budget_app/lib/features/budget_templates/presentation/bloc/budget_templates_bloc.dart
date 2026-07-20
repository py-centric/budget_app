import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/budget_template.dart';
import '../../domain/repositories/budget_templates_repository.dart';
import 'budget_templates_event.dart';
import 'budget_templates_state.dart';

class BudgetTemplatesBloc extends Bloc<BudgetTemplatesEvent, BudgetTemplatesState> {
  final BudgetTemplatesRepository _repository;
  final _uuid = const Uuid();

  BudgetTemplatesBloc({required BudgetTemplatesRepository repository})
      : _repository = repository,
        super(const BudgetTemplatesInitial()) {
    on<LoadAllTemplates>(_onLoadAllTemplates);
    on<CreateTemplateEvent>(_onCreateTemplate);
    on<UpdateTemplateEvent>(_onUpdateTemplate);
    on<DeleteTemplateEvent>(_onDeleteTemplate);
    on<ApplyTemplateEvent>(_onApplyTemplate);
  }

  Future<void> _onLoadAllTemplates(LoadAllTemplates event, Emitter<BudgetTemplatesState> emit) async {
    emit(const BudgetTemplatesLoading());
    final templates = await _repository.getAllTemplates();
    emit(BudgetTemplatesLoaded(templates));
  }

  Future<void> _onCreateTemplate(CreateTemplateEvent event, Emitter<BudgetTemplatesState> emit) async {
    final template = BudgetTemplate(
      id: _uuid.v4(),
      name: event.name,
      description: event.description,
      createdAt: DateTime.now(),
    );
    await _repository.createTemplate(template);
    if (event.allocations.isNotEmpty) {
      await _repository.saveAllocations(template.id, event.allocations);
    }
    final templates = await _repository.getAllTemplates();
    emit(BudgetTemplatesLoaded(templates));
  }

  Future<void> _onUpdateTemplate(UpdateTemplateEvent event, Emitter<BudgetTemplatesState> emit) async {
    await _repository.updateTemplate(event.template);
    if (event.allocations.isNotEmpty) {
      await _repository.saveAllocations(event.template.id, event.allocations);
    }
    final templates = await _repository.getAllTemplates();
    emit(BudgetTemplatesLoaded(templates));
  }

  Future<void> _onDeleteTemplate(DeleteTemplateEvent event, Emitter<BudgetTemplatesState> emit) async {
    await _repository.deleteTemplate(event.templateId);
    final templates = await _repository.getAllTemplates();
    emit(BudgetTemplatesLoaded(templates));
  }

  Future<void> _onApplyTemplate(ApplyTemplateEvent event, Emitter<BudgetTemplatesState> emit) async {
    final allocations = await _repository.getAllocationsForTemplate(event.templateId);
    if (allocations.isEmpty) {
      emit(const BudgetTemplatesError('Template has no category allocations'));
      return;
    }
    final categoryAmounts = <String, double>{};
    for (final allocation in allocations) {
      categoryAmounts[allocation.categoryId] = event.totalBudget * allocation.percentage / 100;
    }
    emit(TemplateApplied(categoryAmounts));
  }
}
