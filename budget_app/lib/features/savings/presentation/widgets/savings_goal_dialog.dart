import 'package:flutter/material.dart';
import '../../domain/entities/savings_goal.dart';

class SavingsGoalDialog extends StatefulWidget {
  final SavingsGoal? existingGoal;
  final Function(
    String name,
    double targetAmount,
    DateTime? deadline,
    String? linkedCategoryId,
    String? icon,
    String? color,
  )
  onSave;

  const SavingsGoalDialog({super.key, this.existingGoal, required this.onSave});

  @override
  State<SavingsGoalDialog> createState() => _SavingsGoalDialogState();
}

class _SavingsGoalDialogState extends State<SavingsGoalDialog> {
  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  DateTime? _deadline;
  String _selectedIcon = 'savings';
  String _selectedColor = 'blue';

  static const List<String> _availableIcons = [
    'savings',
    'account_balance_wallet',
    'flight',
    'home',
    'directions_car',
    'school',
    'celebration',
    'shopping_bag',
  ];

  static const List<String> _availableColors = [
    'blue',
    'green',
    'orange',
    'purple',
    'red',
    'teal',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingGoal?.name ?? '',
    );
    _targetAmountController = TextEditingController(
      text: widget.existingGoal?.targetAmount.toStringAsFixed(2) ?? '',
    );
    _deadline = widget.existingGoal?.deadline;
    _selectedIcon = widget.existingGoal?.icon ?? 'savings';
    _selectedColor = widget.existingGoal?.color ?? 'blue';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingGoal != null
            ? 'Edit Savings Goal'
            : 'Create Savings Goal',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Goal Name',
                hintText: 'e.g., Emergency Fund, Vacation',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetAmountController,
              decoration: const InputDecoration(
                labelText: 'Target Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDeadline,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Deadline (Optional)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _deadline != null
                      ? '${_deadline!.month}/${_deadline!.day}/${_deadline!.year}'
                      : 'No deadline',
                  style: TextStyle(
                    color: _deadline != null ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Icon', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableIcons.map((iconName) {
                final isSelected = iconName == _selectedIcon;
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = iconName),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getColor(_selectedColor).withValues(alpha: 0.2)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: _getColor(_selectedColor),
                              width: 2,
                            )
                          : null,
                    ),
                    child: Icon(
                      _getIcon(iconName),
                      color: isSelected
                          ? _getColor(_selectedColor)
                          : Colors.grey[600],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Color', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableColors.map((colorName) {
                final isSelected = colorName == _selectedColor;
                return InkWell(
                  onTap: () => setState(() => _selectedColor = colorName),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _getColor(colorName),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _getColor(
                                  colorName,
                                ).withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
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
    if (_nameController.text.trim().isEmpty) return false;
    final amount = double.tryParse(_targetAmountController.text);
    return amount != null && amount > 0;
  }

  Future<void> _selectDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  void _handleSave() {
    widget.onSave(
      _nameController.text.trim(),
      double.parse(_targetAmountController.text),
      _deadline,
      null,
      _selectedIcon,
      _selectedColor,
    );
    Navigator.of(context).pop();
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'savings':
        return Icons.savings;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'flight':
        return Icons.flight;
      case 'home':
        return Icons.home;
      case 'directions_car':
        return Icons.directions_car;
      case 'school':
        return Icons.school;
      case 'celebration':
        return Icons.celebration;
      case 'shopping_bag':
        return Icons.shopping_bag;
      default:
        return Icons.savings;
    }
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }
}
