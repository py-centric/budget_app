import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_limit.dart';

class CategoryLimitDialog extends StatefulWidget {
  final List<Category> categories;
  final CategoryLimit? existingLimit;
  final Function(String categoryId, double amount, LimitPeriod period) onSave;

  const CategoryLimitDialog({
    super.key,
    required this.categories,
    this.existingLimit,
    required this.onSave,
  });

  @override
  State<CategoryLimitDialog> createState() => _CategoryLimitDialogState();
}

class _CategoryLimitDialogState extends State<CategoryLimitDialog> {
  late String? _selectedCategoryId;
  late TextEditingController _amountController;
  late LimitPeriod _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.existingLimit?.categoryId;
    _amountController = TextEditingController(
      text: widget.existingLimit?.amount.toStringAsFixed(2) ?? '',
    );
    _selectedPeriod = widget.existingLimit?.period ?? LimitPeriod.monthly;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseCategories = widget.categories
        .where((c) => c.type == CategoryType.expense)
        .toList();

    return AlertDialog(
      title: Text(
        widget.existingLimit != null ? 'Edit Limit' : 'Set Category Limit',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: expenseCategories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Limit Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<LimitPeriod>(
              segments: const [
                ButtonSegment(
                  value: LimitPeriod.weekly,
                  label: Text('Weekly'),
                  icon: Icon(Icons.calendar_view_week),
                ),
                ButtonSegment(
                  value: LimitPeriod.monthly,
                  label: Text('Monthly'),
                  icon: Icon(Icons.calendar_month),
                ),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (selection) {
                setState(() {
                  _selectedPeriod = selection.first;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isValid ? _handleSave : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  bool get _isValid {
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      return false;
    }
    final amount = double.tryParse(_amountController.text);
    return amount != null && amount > 0;
  }

  void _handleSave() {
    if (_selectedCategoryId == null) return;

    final amount = double.parse(_amountController.text);
    widget.onSave(_selectedCategoryId!, amount, _selectedPeriod);
    Navigator.of(context).pop();
  }
}
