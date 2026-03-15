import '../../domain/entities/category.dart';
import '../../domain/repositories/budget_repository.dart';

class AddCategory {
  final BudgetRepository repository;
  AddCategory(this.repository);
  Future<void> call(Category category) async => await repository.addCategory(category);
}

class UpdateCategory {
  final BudgetRepository repository;
  UpdateCategory(this.repository);
  Future<void> call(Category category) async => await repository.updateCategory(category);
}

class DeleteCategory {
  final BudgetRepository repository;
  DeleteCategory(this.repository);
  Future<void> call(String id) async => await repository.deleteCategory(id);
}

class ReassignAndDeleteCategory {
  final BudgetRepository repository;
  ReassignAndDeleteCategory(this.repository);
  Future<void> call(String oldId, String newId) async => await repository.reassignAndDeleteCategory(oldId, newId);
}
