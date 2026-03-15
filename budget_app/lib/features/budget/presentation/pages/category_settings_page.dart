import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/category_bloc.dart';
import '../../domain/entities/category.dart';
import '../widgets/category_delete_dialog.dart';

class CategorySettingsPage extends StatelessWidget {
  const CategorySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CategoriesLoadedState) {
            final incomeCategories = state.categories.where((c) => c.type == CategoryType.income).toList();
            final expenseCategories = state.categories.where((c) => c.type == CategoryType.expense).toList();

            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [Tab(text: 'Income'), Tab(text: 'Expense')],
                    labelColor: Colors.black,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildCategoryList(context, incomeCategories, CategoryType.income),
                        _buildCategoryList(context, expenseCategories, CategoryType.expense),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, List<Category> categories, CategoryType type) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          title: Text(category.name),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => CategoryDeleteDialog(
                  category: category,
                  availableCategories: categories.where((c) => c.id != category.id).toList(),
                  onConfirm: (reassignedId) {
                    context.read<CategoryBloc>().add(
                      RemoveCategory(id: category.id, reassignedId: reassignedId),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    CategoryType selectedType = CategoryType.expense;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
              ),
              DropdownButton<CategoryType>(
                value: selectedType,
                items: const [
                  DropdownMenuItem(value: CategoryType.income, child: Text('Income')),
                  DropdownMenuItem(value: CategoryType.expense, child: Text('Expense')),
                ],
                onChanged: (value) => setState(() => selectedType = value!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  context.read<CategoryBloc>().add(
                    CreateCategory(name: nameController.text, type: selectedType),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
