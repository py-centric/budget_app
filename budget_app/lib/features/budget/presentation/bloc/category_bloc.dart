import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/manage_categories.dart';
import '../../domain/repositories/budget_repository.dart';

// Events
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {}

class CreateCategory extends CategoryEvent {
  final String name;
  final CategoryType type;
  final String? icon;
  const CreateCategory({required this.name, required this.type, this.icon});
}

class RemoveCategory extends CategoryEvent {
  final String id;
  final String? reassignedId;
  const RemoveCategory({required this.id, this.reassignedId});
}

// States
abstract class CategoryState extends Equatable {
  const CategoryState();
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}
class CategoryLoading extends CategoryState {}
class CategoriesLoadedState extends CategoryState {
  final List<Category> categories;
  const CategoriesLoadedState(this.categories);
  @override
  List<Object?> get props => [categories];
}
class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);
}

// Bloc
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final BudgetRepository repository;
  final AddCategory addCategoryUseCase;
  final DeleteCategory deleteCategoryUseCase;
  final ReassignAndDeleteCategory reassignAndDeleteCategoryUseCase;
  final Uuid _uuid = const Uuid();

  CategoryBloc({
    required this.repository,
    required this.addCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.reassignAndDeleteCategoryUseCase,
  }) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<CreateCategory>(_onCreateCategory);
    on<RemoveCategory>(_onRemoveCategory);
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final categories = await repository.getCategories();
      emit(CategoriesLoadedState(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onCreateCategory(CreateCategory event, Emitter<CategoryState> emit) async {
    final name = event.name.trim();
    if (name.isEmpty) {
      emit(const CategoryError('Category name cannot be empty.'));
      return;
    }

    try {
      final categories = await repository.getCategories();
      if (categories.any((c) => c.name.toLowerCase() == name.toLowerCase() && c.type == event.type)) {
        emit(const CategoryError('Category already exists.'));
        return;
      }

      final category = Category(
        id: _uuid.v4(),
        name: name,
        type: event.type,
        icon: event.icon,
      );
      await addCategoryUseCase(category);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onRemoveCategory(RemoveCategory event, Emitter<CategoryState> emit) async {
    try {
      if (event.reassignedId != null) {
        await reassignAndDeleteCategoryUseCase(event.id, event.reassignedId!);
      } else {
        await deleteCategoryUseCase(event.id);
      }
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
