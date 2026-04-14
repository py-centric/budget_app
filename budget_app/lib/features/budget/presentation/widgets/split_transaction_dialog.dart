import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';

class SplitItem {
  final String categoryId;
  final double amount;
  final String? note;

  SplitItem({required this.categoryId, required this.amount, this.note});
}

class SplitTransactionDialog extends StatefulWidget {
  final List<Category> categories;
  final double totalAmount;
  final List<SplitItem>? existingSplits;
  final Function(List<SplitItem> splits) onSave;
  final bool isExpense;

  const SplitTransactionDialog({
    super.key,
    required this.categories,
    required this.totalAmount,
    this.existingSplits,
    required this.onSave,
    this.isExpense = true,
  });

  @override
  State<SplitTransactionDialog> createState() => _SplitTransactionDialogState();
}

class _SplitTransactionDialogState extends State<SplitTransactionDialog> {
  late List<SplitItem> _splits;
  final List<TextEditingController> _amountControllers = [];
  final List<TextEditingController> _noteControllers = [];
  late String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categories.isNotEmpty
        ? widget.categories.first.id
        : null;

    if (widget.existingSplits != null && widget.existingSplits!.isNotEmpty) {
      _splits = List.from(widget.existingSplits!);
    } else {
      _splits = [
        SplitItem(categoryId: _selectedCategoryId!, amount: widget.totalAmount),
      ];
    }

    for (final split in _splits) {
      _amountControllers.add(
        TextEditingController(text: split.amount.toStringAsFixed(2)),
      );
      _noteControllers.add(TextEditingController(text: split.note ?? ''));
    }
  }

  @override
  void dispose() {
    for (final controller in _amountControllers) {
      controller.dispose();
    }
    for (final controller in _noteControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  double get _totalSplitAmount {
    return _splits.fold(0, (sum, split) => sum + split.amount);
  }

  double get _remainingAmount {
    return widget.totalAmount - _totalSplitAmount;
  }

  bool get _isValid {
    if (_splits.isEmpty) return false;
    final total = _totalSplitAmount;
    return (total - widget.totalAmount).abs() < 0.01;
  }

  void _addSplit() {
    setState(() {
      _splits.add(
        SplitItem(
          categoryId: widget.categories.isNotEmpty
              ? widget.categories.first.id
              : '',
          amount: _remainingAmount > 0 ? _remainingAmount : 0,
        ),
      );
      _amountControllers.add(
        TextEditingController(
          text: _remainingAmount > 0 ? _remainingAmount.toStringAsFixed(2) : '',
        ),
      );
      _noteControllers.add(TextEditingController());
    });
  }

  void _removeSplit(int index) {
    if (_splits.length <= 1) return;
    setState(() {
      _splits.removeAt(index);
      _amountControllers[index].dispose();
      _noteControllers[index].dispose();
      _amountControllers.removeAt(index);
      _noteControllers.removeAt(index);
    });
  }

  void _updateSplitAmount(int index, double amount) {
    setState(() {
      _splits[index] = SplitItem(
        categoryId: _splits[index].categoryId,
        amount: amount,
        note: _splits[index].note,
      );
    });
  }

  void _updateSplitCategory(int index, String categoryId) {
    setState(() {
      _splits[index] = SplitItem(
        categoryId: categoryId,
        amount: _splits[index].amount,
        note: _splits[index].note,
      );
    });
  }

  void _updateSplitNote(int index, String note) {
    setState(() {
      _splits[index] = SplitItem(
        categoryId: _splits[index].categoryId,
        amount: _splits[index].amount,
        note: note.isEmpty ? null : note,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Split Transaction'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount:', style: theme.textTheme.bodyMedium),
                  Text(
                    '\$${widget.totalAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Split Details',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _splits.length,
                itemBuilder: (context, index) {
                  return _buildSplitRow(context, index);
                },
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _addSplit,
              icon: const Icon(Icons.add),
              label: const Text('Add Split'),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _remainingAmount.abs() < 0.01
                    ? Colors.green.withValues(alpha: 0.1)
                    : _remainingAmount < 0
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _remainingAmount.abs() < 0.01
                        ? 'Split evenly!'
                        : _remainingAmount < 0
                        ? 'Over by:'
                        : 'Remaining:',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    '\$${_remainingAmount.abs().toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _remainingAmount.abs() < 0.01
                          ? Colors.green
                          : _remainingAmount < 0
                          ? Colors.red
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
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

  Widget _buildSplitRow(BuildContext context, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _splits[index].categoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: widget.categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _updateSplitCategory(index, value);
                      }
                    },
                  ),
                ),
                if (_splits.length > 1)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => _removeSplit(index),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountControllers[index],
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) {
                      final amount = double.tryParse(value) ?? 0;
                      _updateSplitAmount(index, amount);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteControllers[index],
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) => _updateSplitNote(index, value),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave() {
    final splits = _splits
        .map(
          (s) => SplitItem(
            categoryId: s.categoryId,
            amount: s.amount,
            note: s.note,
          ),
        )
        .toList();
    widget.onSave(splits);
    Navigator.of(context).pop();
  }
}
