import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('should have correct appName', () {
      expect(AppConstants.appName, 'Budget App');
    });

    test('should have correct databaseName', () {
      expect(AppConstants.databaseName, 'budget.db');
    });

    test('should have correct databaseVersion', () {
      expect(AppConstants.databaseVersion, 17);
    });

    test('should have defaultCategories list', () {
      expect(AppConstants.defaultCategories, isNotEmpty);
      expect(AppConstants.defaultCategories, contains('Food'));
      expect(AppConstants.defaultCategories, contains('Transport'));
      expect(AppConstants.defaultCategories, contains('Utilities'));
      expect(AppConstants.defaultCategories.length, 8);
    });

    test('defaultCategories should not contain duplicates', () {
      expect(
        AppConstants.defaultCategories.toSet().length,
        AppConstants.defaultCategories.length,
      );
    });
  });
}
