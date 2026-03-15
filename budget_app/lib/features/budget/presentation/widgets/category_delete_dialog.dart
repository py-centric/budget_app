import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';

class CategoryDeleteDialog extends StatefulWidget {
  final Category category;
  final List<Category> availableCategories;
  final Function(String? reassignedId) onConfirm;

  const CategoryDeleteDialog({
    super.key,
    required this.category,
    required this.availableCategories,
    required this.onConfirm,
  });

  @override
  State<CategoryDeleteDialog> createState() => _CategoryDeleteDialogState();
}

class _CategoryDeleteDialogState extends State<CategoryDeleteDialog> {
  String? _selectedReassignedId;

  @override
  void initState() {
    super.initState();
    if (widget.availableCategories.isNotEmpty) {
      _selectedReassignedId = widget.availableCategories.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Category: ${widget.category.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Re-assign existing transactions to:'),
          const SizedBox(height: 16),
          if (widget.availableCategories.isNotEmpty)
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedReassignedId,
              items: widget.availableCategories.map((c) {
                return DropdownMenuItem(value: c.id, child: Text(c.name));
              }).toList(),
              onChanged: (value) => setState(() => _selectedReassignedId = value),
            )
          else
            const Text('No other categories available. Transactions will be deleted or orphaned.', style: TextStyle(color: Colors.red)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            widget.onConfirm(_selectedReassignedId);
            Navigator.pop(context);
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
