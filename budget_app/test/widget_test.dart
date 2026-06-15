import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:budget_app/features/budget/data/datasources/local_database.dart';
import 'package:budget_app/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:budget_app/core/constants/app_constants.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  late MockStorage mockStorage;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    mockStorage = MockStorage();
    when(
      () => mockStorage.write(any(), any<dynamic>()),
    ).thenAnswer((_) async {});
    when(() => mockStorage.read(any())).thenAnswer((_) async => null);
    when(() => mockStorage.delete(any())).thenAnswer((_) async {});
    HydratedBloc.storage = mockStorage;
  });

  group('App initialization smoke test', () {
    test('LocalDatabase initializes with correct database name', () async {
      await LocalDatabase.initialize();
      final db = await LocalDatabase.instance.database;

      expect(db.isOpen, true);
      expect(db.path, endsWith(AppConstants.databaseName));

      // Verify core tables exist after schema creation
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
      );
      final tableNames = tables.map((t) => t['name'] as String).toList();

      expect(tableNames, contains('budgets'));
      expect(tableNames, contains('income_entries'));
      expect(tableNames, contains('expense_entries'));
      expect(tableNames, contains('categories'));

      await db.close();
    });

    test('BudgetRepositoryImpl can be created with LocalDatabase instance', () {
      final repository = BudgetRepositoryImpl(LocalDatabase.instance);
      expect(repository, isNotNull);
    });
  });
}
