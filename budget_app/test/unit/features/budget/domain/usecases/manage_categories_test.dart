import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:budget_app/features/budget/domain/usecases/manage_categories.dart';
import 'package:budget_app/features/budget/domain/repositories/budget_repository.dart';
import 'package:budget_app/features/budget/domain/entities/category.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

class FakeCategory extends Fake implements Category {}

void main() {
  late MockBudgetRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeCategory());
  });

  setUp(() {
    mockRepository = MockBudgetRepository();
  });

  group('AddCategory', () {
    test('should add category to repository', () async {
      final usecase = AddCategory(mockRepository);
      const category = Category(
        id: '1',
        name: 'New Category',
        type: CategoryType.expense,
      );

      when(() => mockRepository.addCategory(any())).thenAnswer((_) async {});

      await usecase.call(category);

      verify(() => mockRepository.addCategory(category)).called(1);
    });
  });

  group('UpdateCategory', () {
    test('should update category in repository', () async {
      final usecase = UpdateCategory(mockRepository);
      const category = Category(
        id: '1',
        name: 'Updated Category',
        type: CategoryType.income,
      );

      when(() => mockRepository.updateCategory(any())).thenAnswer((_) async {});

      await usecase.call(category);

      verify(() => mockRepository.updateCategory(category)).called(1);
    });
  });

  group('DeleteCategory', () {
    test('should delete category from repository', () async {
      final usecase = DeleteCategory(mockRepository);

      when(() => mockRepository.deleteCategory('1')).thenAnswer((_) async {});

      await usecase.call('1');

      verify(() => mockRepository.deleteCategory('1')).called(1);
    });
  });

  group('ReassignAndDeleteCategory', () {
    test('should reassign and delete category', () async {
      final usecase = ReassignAndDeleteCategory(mockRepository);

      when(
        () => mockRepository.reassignAndDeleteCategory('old-1', 'new-1'),
      ).thenAnswer((_) async {});

      await usecase.call('old-1', 'new-1');

      verify(
        () => mockRepository.reassignAndDeleteCategory('old-1', 'new-1'),
      ).called(1);
    });
  });
}
