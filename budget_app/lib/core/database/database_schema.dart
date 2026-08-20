import 'package:sqflite/sqflite.dart';
import 'package:budget_app/core/constants/app_constants.dart';
import 'database_tables.dart';
import 'database_indices.dart';

class DatabaseSchema {
  static Future<void> onCreate(Database db, int version) async {
    await createTables(db);
    await createIndices(db);
    await seedInitialData(db);
  }

  static Future<void> createTables(Database db) async {
    for (final sql in DatabaseTables.allTables) {
      await db.execute(sql);
    }
  }

  static Future<void> createIndices(Database db) async {
    for (final sql in DatabaseIndices.allIndices) {
      await db.execute(sql);
    }
  }

  static Future<void> seedInitialData(Database db) async {
    // Add default expense categories
    for (final category in AppConstants.defaultCategories) {
      await db.insert('categories', {
        'id': category.toLowerCase(),
        'name': category,
        'type': 'expense',
        'icon': getCategoryIcon(category),
      });
    }

    // Add default income categories
    const defaultIncomeCategories = [
      'Salary',
      'Gift',
      'Interest',
      'Investment',
      'Other',
    ];
    for (final cat in defaultIncomeCategories) {
      await db.insert('categories', {
        'id': 'income_${cat.toLowerCase()}',
        'name': cat,
        'type': 'income',
        'icon': getCategoryIcon(cat),
      });
    }
  }

  static String getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return 'restaurant';
      case 'transport':
        return 'directions_car';
      case 'utilities':
        return 'lightbulb';
      case 'entertainment':
        return 'movie';
      case 'shopping':
        return 'shopping_bag';
      case 'health':
        return 'local_hospital';
      case 'education':
        return 'school';
      default:
        return 'category';
    }
  }
}
