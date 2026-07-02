import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/core/theme/app_spacing.dart';
import 'package:budget_app/core/utils/currency_formatter.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/usecases/calculate_required_contribution.dart';

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
  late TextEditingController _rateController;
  late TextEditingController _yearsController;
  DateTime? _deadline;
  String _selectedIcon = 'savings';
  String _selectedColor = 'blue';

  final _calculator = CalculateRequiredContribution();

  double? _calculatedMonthly;

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
    _rateController = TextEditingController();
    _yearsController = TextEditingController();
    _deadline = widget.existingGoal?.deadline;
    _selectedIcon = widget.existingGoal?.icon ?? 'savings';
    _selectedColor = widget.existingGoal?.color ?? 'blue';

    _targetAmountController.addListener(_updateCalculation);
    _rateController.addListener(_updateCalculation);
    _yearsController.addListener(_updateCalculation);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    final target = double.tryParse(_targetAmountController.text);
    final rate = double.tryParse(_rateController.text);
    final years = int.tryParse(_yearsController.text);

    if (target != null && target > 0 && rate != null && years != null && years > 0) {
      final result = _calculator(
        targetAmount: target,
        currentAmount: widget.existingGoal?.currentAmount ?? 0,
        annualRate: rate,
        years: years,
      );
      setState(() {
        _calculatedMonthly = result;
      });
    } else {
      setState(() {
        _calculatedMonthly = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = context
        .read<SettingsBloc>()
        .state
        .settings
        .currencyCode;
    final calcTheme = Theme.of(context);
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
            SizedBox(height: AppSpacing.md),
            TextField(
              controller: _targetAmountController,
              decoration: InputDecoration(
                labelText: 'Target Amount',
                prefixText: '${CurrencyFormatter.getSymbol(currencyCode: currencyCode)} ',
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            SizedBox(height: AppSpacing.md),
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
                    color: _deadline != null ? null : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            const Divider(),
            Text(
              'Savings Calculator (Optional)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Set a return rate and duration to see your required monthly contribution.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.sm + AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rateController,
                    decoration: const InputDecoration(
                      labelText: 'Annual Return (%)',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: AppSpacing.sm + AppSpacing.xs),
                Expanded(
                  child: TextField(
                    controller: _yearsController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (Years)',
                      border: OutlineInputBorder(),
                      suffixText: 'yr',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            if (_calculatedMonthly != null) ...[
              SizedBox(height: AppSpacing.sm + AppSpacing.xs),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: calcTheme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: calcTheme.colorScheme.tertiary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calculate,
                          size: 16,
                          color: calcTheme.colorScheme.tertiary,
                        ),
                        SizedBox(width: AppSpacing.sm - 2),
                        Text(
                          'Required Monthly Contribution',
                          style: calcTheme.textTheme.bodySmall?.copyWith(
                            color: calcTheme.colorScheme.tertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      CurrencyFormatter.format(_calculatedMonthly!, currencyCode: currencyCode),
                      style: calcTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: calcTheme.colorScheme.tertiary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _buildSummaryText(),
                      style: calcTheme.textTheme.bodySmall?.copyWith(
                        color: calcTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: AppSpacing.md),
            const Divider(),
            Text('Icon', style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: AppSpacing.sm),
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
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
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
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: AppSpacing.md),
            Text('Color', style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: AppSpacing.sm),
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
                          ? Border.all(color: Theme.of(context).colorScheme.surface, width: 3)
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

  String _buildSummaryText() {
    final target = double.tryParse(_targetAmountController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0;
    final years = int.tryParse(_yearsController.text) ?? 0;
    final currencyCode = context.read<SettingsBloc>().state.settings.currencyCode;
    return 'To reach ${CurrencyFormatter.format(target, currencyCode: currencyCode)} in $years years at ${rate.toStringAsFixed(1)}% APY';
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
