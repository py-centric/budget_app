import 'package:flutter/material.dart';
import 'package:budget_app/core/theme/app_spacing.dart';
import 'package:budget_app/core/utils/currency_formatter.dart';
import '../../domain/usecases/calculate_required_contribution.dart';

class SavingsCalculatorDialog extends StatefulWidget {
  const SavingsCalculatorDialog({super.key});

  @override
  State<SavingsCalculatorDialog> createState() => _SavingsCalculatorDialogState();
}

class _SavingsCalculatorDialogState extends State<SavingsCalculatorDialog> {
  late TextEditingController _targetController;
  late TextEditingController _rateController;
  late TextEditingController _yearsController;

  final _calculator = CalculateRequiredContribution();

  double? _calculatedMonthly;

  @override
  void initState() {
    super.initState();
    _targetController = TextEditingController();
    _rateController = TextEditingController();
    _yearsController = TextEditingController();
    _targetController.addListener(_updateCalculation);
    _rateController.addListener(_updateCalculation);
    _yearsController.addListener(_updateCalculation);
  }

  @override
  void dispose() {
    _targetController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  void _updateCalculation() {
    final target = double.tryParse(_targetController.text);
    final rate = double.tryParse(_rateController.text);
    final years = int.tryParse(_yearsController.text);

    if (target != null && target > 0 && rate != null && years != null && years > 0) {
      final result = _calculator(
        targetAmount: target,
        currentAmount: 0,
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
    return AlertDialog(
      title: const Text('Savings Goal Calculator'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Calculate how much you need to save each month to reach your goal.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _targetController,
              decoration: InputDecoration(
                labelText: 'Target Amount',
                prefixText: '${CurrencyFormatter.getSymbol(currencyCode: 'USD')} ',
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
            TextField(
              controller: _rateController,
              decoration: const InputDecoration(
                labelText: 'Annual Return Rate (%)',
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
            TextField(
              controller: _yearsController,
              decoration: const InputDecoration(
                labelText: 'Duration (Years)',
                border: OutlineInputBorder(),
                suffixText: 'yr',
              ),
              keyboardType: TextInputType.number,
            ),
            if (_calculatedMonthly != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3),
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
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const SizedBox(width: AppSpacing.sm - 2),
                        Text(
                          'Required Monthly Contribution',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      CurrencyFormatter.format(_calculatedMonthly!, currencyCode: 'USD'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _buildSummaryText(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _buildSummaryText() {
    final target = double.tryParse(_targetController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0;
    final years = int.tryParse(_yearsController.text) ?? 0;
    return 'To reach ${CurrencyFormatter.format(target, currencyCode: 'USD')} in $years years at ${rate.toStringAsFixed(1)}% APY, you need to contribute ${CurrencyFormatter.format(_calculatedMonthly ?? 0, currencyCode: 'USD')}/month';
  }
}
