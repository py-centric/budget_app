import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/recurring_templates/domain/entities/recurring_template.dart';

void main() {
  group('RecurringTemplate', () {
    final template = RecurringTemplate(
      id: 'rt-1',
      name: 'Netflix Subscription',
      description: 'Monthly streaming service',
      type: 'subscription',
      defaultAmount: 15.99,
      defaultCategoryId: 'entertainment',
      defaultInterval: 1,
      defaultUnit: 'months',
    );

    test('props are correct', () {
      expect(template.props, [
        'rt-1', 'Netflix Subscription', 'Monthly streaming service',
        'subscription', 15.99, 'entertainment', 1, 'months',
      ]);
    });

    test('equality works', () {
      final template2 = RecurringTemplate(
        id: 'rt-1', name: 'Netflix Subscription',
        description: 'Monthly streaming service',
        type: 'subscription', defaultAmount: 15.99,
        defaultCategoryId: 'entertainment',
      );
      expect(template, equals(template2));
    });

    test('inequality with different id', () {
      final template2 = RecurringTemplate(
        id: 'rt-2', name: 'Netflix Subscription',
        description: 'Monthly streaming service',
        type: 'subscription', defaultAmount: 15.99,
        defaultCategoryId: 'entertainment',
      );
      expect(template, isNot(equals(template2)));
    });

    test('default values for optional fields', () {
      final template = RecurringTemplate(
        id: 'rt-1', name: 'Test', description: 'Test',
        type: 'bill', defaultAmount: 100, defaultCategoryId: 'bills',
      );
      expect(template.defaultInterval, 1);
      expect(template.defaultUnit, 'months');
    });
  });
}
