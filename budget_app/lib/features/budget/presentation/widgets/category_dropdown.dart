import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category.dart';
import '../bloc/category_bloc.dart';

class CategoryDropdown extends StatefulWidget {
  final List<Category> categories;
  final CategoryType? filterType;
  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final String labelText;

  const CategoryDropdown({
    super.key,
    required this.categories,
    this.filterType,
    this.initialValue,
    required this.onChanged,
    this.validator,
    this.labelText = 'Category',
  });

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  String? _pendingNewCategoryName;
  CategoryType? _pendingNewCategoryType;
  bool? _hasCategoryBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final available = _isCategoryBlocAvailable();
    if (_hasCategoryBloc == null || _hasCategoryBloc != available) {
      setState(() {
        _hasCategoryBloc = available;
      });
    }
  }

  bool _isCategoryBlocAvailable() {
    try {
      context.read<CategoryBloc>();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    CategoryType selectedType = widget.filterType ?? CategoryType.expense;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    if (widget.filterType == null)
                      DropdownButtonFormField<CategoryType>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
                        items: CategoryType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type.name[0].toUpperCase() +
                                  type.name.substring(1),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedType = value;
                            });
                          }
                        },
                      )
                    else
                      Text(
                        'Type: ${widget.filterType!.name[0].toUpperCase() + widget.filterType!.name.substring(1)}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      setState(() {
                        _pendingNewCategoryName = name;
                        _pendingNewCategoryType = selectedType;
                      });
                      try {
                        context
                            .read<CategoryBloc>()
                            .add(CreateCategory(name: name, type: selectedType));
                      } catch (_) {}
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDropdown(List<Category> categories) {
    return DropdownButtonFormField<String>(
      initialValue: widget.initialValue,
      decoration: InputDecoration(labelText: widget.labelText),
      items: [
        ...categories.map((category) {
          return DropdownMenuItem(
            value: category.id,
            child: Text(category.name),
          );
        }),
        if (categories.isNotEmpty && _hasCategoryBloc == true)
          const DropdownMenuItem(
            value: null,
            enabled: false,
            child: Divider(height: 1),
          ),
        if (_hasCategoryBloc == true)
          const DropdownMenuItem(
            value: '__add_new__',
            child: Text('➕ Add New Category...'),
          ),
      ],
      onChanged: (value) {
        if (value == '__add_new__') {
          _showAddCategoryDialog();
          return;
        }
        widget.onChanged(value);
      },
      validator: widget.validator,
    );
  }

  List<Category> _getFiltered(List<Category> categories) {
    if (widget.filterType == null) return categories;
    return categories.where((c) => c.type == widget.filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasCategoryBloc != true) {
      return _buildDropdown(_getFiltered(widget.categories));
    }

    return BlocListener<CategoryBloc, CategoryState>(
      listenWhen: (previous, current) =>
          current is CategoriesLoadedState && _pendingNewCategoryName != null,
      listener: (context, state) {
        if (state is CategoriesLoadedState) {
          final matching = state.categories.where((c) =>
              c.name.toLowerCase() == _pendingNewCategoryName!.toLowerCase() &&
              c.type == _pendingNewCategoryType);
          if (matching.isNotEmpty) {
            final newId = matching.first.id;
            _pendingNewCategoryName = null;
            _pendingNewCategoryType = null;
            widget.onChanged(newId);
          }
        }
      },
      child: BlocBuilder<CategoryBloc, CategoryState>(
        buildWhen: (previous, current) => current is CategoriesLoadedState,
        builder: (context, state) {
          final allCategories = state is CategoriesLoadedState
              ? state.categories
              : widget.categories;

          return _buildDropdown(_getFiltered(allCategories));
        },
      ),
    );
  }
}
