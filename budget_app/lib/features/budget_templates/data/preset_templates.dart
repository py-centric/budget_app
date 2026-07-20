import '../domain/entities/budget_template.dart';

class PresetTemplates {

  static List<BudgetTemplate> get presets => [
        BudgetTemplate(
          id: 'preset_50_30_20',
          name: '50/30/20 Rule',
          description: '50% needs, 30% wants, 20% savings',
          isPreset: true,
          createdAt: DateTime(2024),
        ),
        BudgetTemplate(
          id: 'preset_70_20_10',
          name: '70/20/10 Rule',
          description: '70% living expenses, 20% savings, 10% debt',
          isPreset: true,
          createdAt: DateTime(2024),
        ),
        BudgetTemplate(
          id: 'preset_zero_based',
          name: 'Zero-Based',
          description: 'Every dollar is assigned a job',
          isPreset: true,
          createdAt: DateTime(2024),
        ),
      ];

  static List<TemplateAllocation> get allocations50_30_20 => [
        const TemplateAllocation(templateId: 'preset_50_30_20', categoryId: 'food', percentage: 15),
        const TemplateAllocation(templateId: 'preset_50_30_20', categoryId: 'transport', percentage: 10),
        const TemplateAllocation(templateId: 'preset_50_30_20', categoryId: 'utilities', percentage: 10),
        const TemplateAllocation(templateId: 'preset_50_30_20', categoryId: 'entertainment', percentage: 15),
        const TemplateAllocation(templateId: 'preset_50_30_20', categoryId: 'shopping', percentage: 15),
        const TemplateAllocation(templateId: 'preset_50_30_20', categoryId: 'health', percentage: 5),
        const TemplateAllocation(templateId: 'preset_50_30_20', categoryId: 'education', percentage: 5),
        const TemplateAllocation(templateId: 'preset_50_30_20', categoryId: 'other', percentage: 25),
      ];

  static List<TemplateAllocation> get allocations70_20_10 => [
        const TemplateAllocation(templateId: 'preset_70_20_10', categoryId: 'food', percentage: 25),
        const TemplateAllocation(templateId: 'preset_70_20_10', categoryId: 'transport', percentage: 10),
        const TemplateAllocation(templateId: 'preset_70_20_10', categoryId: 'utilities', percentage: 10),
        const TemplateAllocation(templateId: 'preset_70_20_10', categoryId: 'entertainment', percentage: 10),
        const TemplateAllocation(templateId: 'preset_70_20_10', categoryId: 'shopping', percentage: 5),
        const TemplateAllocation(templateId: 'preset_70_20_10', categoryId: 'health', percentage: 5),
        const TemplateAllocation(templateId: 'preset_70_20_10', categoryId: 'education', percentage: 5),
        const TemplateAllocation(templateId: 'preset_70_20_10', categoryId: 'other', percentage: 25),
      ];

  static List<TemplateAllocation> getAllocations(String templateId) {
    switch (templateId) {
      case 'preset_50_30_20':
        return allocations50_30_20;
      case 'preset_70_20_10':
        return allocations70_20_10;
      default:
        return [];
    }
  }
}
