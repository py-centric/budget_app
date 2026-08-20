import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget_templates/domain/entities/budget_template.dart';

void main() {
  group('BudgetTemplate', () {
    final now = DateTime(2024, 6, 15);
    final template = BudgetTemplate(
      id: 'bt-1',
      name: '50/30/20',
      description: 'Needs/Wants/Savings',
      isPreset: true,
      createdAt: now,
    );

    test('props are correct', () {
      expect(template.props, ['bt-1', '50/30/20', 'Needs/Wants/Savings', true, now]);
    });

    test('copyWith creates new instance', () {
      final updated = template.copyWith(name: 'Conservative');
      expect(updated.name, 'Conservative');
      expect(updated.id, 'bt-1');
      expect(updated, isNot(equals(template)));
    });

    test('copyWith with no args returns equal instance', () {
      expect(template.copyWith(), equals(template));
    });

    test('equality works', () {
      final template2 = BudgetTemplate(
        id: 'bt-1', name: '50/30/20', description: 'Needs/Wants/Savings',
        isPreset: true, createdAt: now,
      );
      expect(template, equals(template2));
    });

    test('toMap serializes correctly', () {
      final map = template.toMap();
      expect(map['id'], 'bt-1');
      expect(map['name'], '50/30/20');
      expect(map['description'], 'Needs/Wants/Savings');
      expect(map['is_preset'], 1);
      expect(map['created_at'], now.toIso8601String());
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'id': 'bt-1', 'name': '50/30/20', 'description': 'Needs/Wants/Savings',
        'is_preset': 1, 'created_at': now.toIso8601String(),
      };
      final result = BudgetTemplate.fromMap(map);
      expect(result.id, 'bt-1');
      expect(result.name, '50/30/20');
      expect(result.isPreset, isTrue);
    });

    test('fromMap with is_preset 0', () {
      final map = {
        'id': 'bt-1', 'name': 'Custom', 'description': null,
        'is_preset': 0, 'created_at': now.toIso8601String(),
      };
      final result = BudgetTemplate.fromMap(map);
      expect(result.isPreset, isFalse);
      expect(result.description, isNull);
    });

    test('toMap with isPreset false', () {
      final custom = template.copyWith(isPreset: false);
      final map = custom.toMap();
      expect(map['is_preset'], 0);
    });
  });

  group('TemplateAllocation', () {
    const alloc = TemplateAllocation(
      templateId: 'bt-1',
      categoryId: 'food',
      percentage: 50.0,
    );

    test('props are correct', () {
      expect(alloc.props, ['bt-1', 'food', 50.0]);
    });

    test('toMap serializes correctly', () {
      final map = alloc.toMap();
      expect(map['template_id'], 'bt-1');
      expect(map['category_id'], 'food');
      expect(map['percentage'], 50.0);
    });

    test('fromMap deserializes correctly', () {
      final map = {'template_id': 'bt-1', 'category_id': 'food', 'percentage': 50.0};
      final result = TemplateAllocation.fromMap(map);
      expect(result.templateId, 'bt-1');
      expect(result.categoryId, 'food');
      expect(result.percentage, 50.0);
    });

    test('equality works', () {
      const alloc2 = TemplateAllocation(templateId: 'bt-1', categoryId: 'food', percentage: 50.0);
      expect(alloc, equals(alloc2));
    });
  });
}
