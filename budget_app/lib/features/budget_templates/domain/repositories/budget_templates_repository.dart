import '../entities/budget_template.dart';

abstract class BudgetTemplatesRepository {
  Future<List<BudgetTemplate>> getAllTemplates();
  Future<BudgetTemplate?> getTemplateById(String id);
  Future<BudgetTemplate> createTemplate(BudgetTemplate template);
  Future<void> updateTemplate(BudgetTemplate template);
  Future<void> deleteTemplate(String id);
  Future<List<TemplateAllocation>> getAllocationsForTemplate(String templateId);
  Future<void> saveAllocations(String templateId, List<TemplateAllocation> allocations);
}
