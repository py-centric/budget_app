import '../../domain/entities/budget_template.dart';
import '../../domain/repositories/budget_templates_repository.dart';
import '../../../budget/data/datasources/local_database.dart';

class BudgetTemplatesRepositoryImpl implements BudgetTemplatesRepository {
  final LocalDatabase _localDatabase;

  BudgetTemplatesRepositoryImpl(this._localDatabase);

  @override
  Future<List<BudgetTemplate>> getAllTemplates() async {
    final db = await _localDatabase.database;
    final maps = await db.query('budget_templates', orderBy: 'is_preset DESC, name ASC');
    return maps.map(BudgetTemplate.fromMap).toList();
  }

  @override
  Future<BudgetTemplate?> getTemplateById(String id) async {
    final db = await _localDatabase.database;
    final maps = await db.query('budget_templates', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return BudgetTemplate.fromMap(maps.first);
  }

  @override
  Future<BudgetTemplate> createTemplate(BudgetTemplate template) async {
    final db = await _localDatabase.database;
    await db.insert('budget_templates', template.toMap());
    return template;
  }

  @override
  Future<void> updateTemplate(BudgetTemplate template) async {
    final db = await _localDatabase.database;
    await db.update('budget_templates', template.toMap(), where: 'id = ?', whereArgs: [template.id]);
  }

  @override
  Future<void> deleteTemplate(String id) async {
    final db = await _localDatabase.database;
    await db.delete('budget_template_allocations', where: 'template_id = ?', whereArgs: [id]);
    await db.delete('budget_templates', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<TemplateAllocation>> getAllocationsForTemplate(String templateId) async {
    final db = await _localDatabase.database;
    final maps = await db.query(
      'budget_template_allocations',
      where: 'template_id = ?',
      whereArgs: [templateId],
    );
    return maps.map(TemplateAllocation.fromMap).toList();
  }

  @override
  Future<void> saveAllocations(String templateId, List<TemplateAllocation> allocations) async {
    final db = await _localDatabase.database;
    await db.delete('budget_template_allocations', where: 'template_id = ?', whereArgs: [templateId]);
    for (final allocation in allocations) {
      await db.insert('budget_template_allocations', allocation.toMap());
    }
  }
}
