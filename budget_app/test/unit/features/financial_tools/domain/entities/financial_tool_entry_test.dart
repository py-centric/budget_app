import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/financial_tools/domain/entities/financial_tool_entry.dart';

void main() {
  group('FinancialToolEntry', () {
    test('should create FinancialToolEntry with required fields', () {
      const entry = FinancialToolEntry(label: 'Monthly Payment', value: 500.0);

      expect(entry.label, 'Monthly Payment');
      expect(entry.value, 500.0);
    });

    test('toMap should return correct map', () {
      const entry = FinancialToolEntry(label: 'Total Interest', value: 1500.0);

      final map = entry.toMap();

      expect(map, {'label': 'Total Interest', 'value': 1500.0});
    });

    test('fromMap should create correct entry', () {
      final map = {'label': 'Principal', 'value': 10000};

      final entry = FinancialToolEntry.fromMap(map);

      expect(entry.label, 'Principal');
      expect(entry.value, 10000.0);
    });

    test('fromMap should handle num values', () {
      final map = {'label': 'Test', 'value': 100.5};

      final entry = FinancialToolEntry.fromMap(map);

      expect(entry.value, 100.5);
    });

    test('props should contain label and value', () {
      const entry = FinancialToolEntry(label: 'Test', value: 100.0);

      expect(entry.props, ['Test', 100.0]);
    });

    test('two entries with same values should be equal', () {
      const entry1 = FinancialToolEntry(label: 'Test', value: 100.0);
      const entry2 = FinancialToolEntry(label: 'Test', value: 100.0);

      expect(entry1, equals(entry2));
    });
  });
}
