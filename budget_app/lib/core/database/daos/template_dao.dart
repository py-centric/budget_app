import 'base_dao.dart';

class TemplateDao extends BaseDao {
  TemplateDao(super.getDb);

  Future<List<Map<String, dynamic>>> getAllTemplates() async {
    final database = await db;
    return await database.query('budget_templates', orderBy: 'is_preset DESC, name ASC');
  }

  Future<Map<String, dynamic>?> getTemplateById(String id) async {
    final database = await db;
    final maps = await database.query('budget_templates', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return maps.first;
  }

  Future<void> createTemplate(Map<String, dynamic> template) async {
    final database = await db;
    await database.insert('budget_templates', template);
  }

  Future<void> updateTemplate(Map<String, dynamic> template) async {
    final database = await db;
    await database.update(
      'budget_templates',
      template,
      where: 'id = ?',
      whereArgs: [template['id']],
    );
  }

  Future<void> deleteTemplate(String id) async {
    final database = await db;
    await database.delete('budget_template_allocations', where: 'template_id = ?', whereArgs: [id]);
    await database.delete('budget_templates', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllocationsForTemplate(
    String templateId,
  ) async {
    final database = await db;
    return await database.query(
      'budget_template_allocations',
      where: 'template_id = ?',
      whereArgs: [templateId],
    );
  }

  Future<void> saveAllocations(
    String templateId,
    List<Map<String, dynamic>> allocations,
  ) async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.delete(
        'budget_template_allocations',
        where: 'template_id = ?',
        whereArgs: [templateId],
      );
      for (final allocation in allocations) {
        await txn.insert('budget_template_allocations', allocation);
      }
    });
  }
}
