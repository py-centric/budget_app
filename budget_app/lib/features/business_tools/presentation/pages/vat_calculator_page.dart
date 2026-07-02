import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/core/theme/app_spacing.dart';
import 'package:budget_app/core/utils/currency_formatter.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';
import '../../domain/usecases/calculate_vat.dart';

class VatCalculatorPage extends StatefulWidget {
  const VatCalculatorPage({super.key});

  @override
  State<VatCalculatorPage> createState() => _VatCalculatorPageState();
}

class _VatCalculatorPageState extends State<VatCalculatorPage> {
  final _calculateVat = CalculateVat();
  final _amountController = TextEditingController();
  final _rateController = TextEditingController(text: '20');

  bool _isNetToGross = true;
  VatResult? _result;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_calculate);
    _rateController.addListener(_calculate);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _calculate() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final rate = double.tryParse(_rateController.text) ?? 0.0;

    if (amount > 0) {
      setState(() {
        if (_isNetToGross) {
          _result = _calculateVat.fromNet(amount, rate);
        } else {
          _result = _calculateVat.fromGross(amount, rate);
        }
      });
    } else {
      setState(() {
        _result = null;
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

    return Scaffold(
      appBar: AppBar(title: const Text('VAT Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('Add VAT'),
                  icon: Icon(Icons.add),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('Remove VAT'),
                  icon: Icon(Icons.remove),
                ),
              ],
              selected: {_isNetToGross},
              onSelectionChanged: (value) {
                setState(() {
                  _isNetToGross = value.first;
                  _calculate();
                });
              },
            ),
            SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: _isNetToGross ? 'Net Amount' : 'Gross Amount',
                prefixText: '${CurrencyFormatter.getSymbol(currencyCode: currencyCode)} ',
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            TextField(
              controller: _rateController,
              decoration: const InputDecoration(
                labelText: 'VAT Rate (%)',
                suffixText: '%',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            if (_result != null) ...[
              _ResultCard(
                title: 'Net Amount',
                value: CurrencyFormatter.format(_result!.netAmount, currencyCode: currencyCode),
                color: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(height: AppSpacing.sm + AppSpacing.xs),
              _ResultCard(
                title: 'VAT Amount (${_result!.vatRate}%)',
                value: CurrencyFormatter.format(_result!.vatAmount, currencyCode: currencyCode),
                color: Theme.of(context).colorScheme.tertiary,
              ),
              SizedBox(height: AppSpacing.sm + AppSpacing.xs),
              _ResultCard(
                title: 'Gross Amount',
                value: CurrencyFormatter.format(_result!.grossAmount, currencyCode: currencyCode),
                color: Theme.of(context).colorScheme.primary,
                isTotal: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final bool isTotal;

  const _ResultCard({
    required this.title,
    required this.value,
    required this.color,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isTotal ? 4 : 1,
      color: isTotal ? color.withValues(alpha: 0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: isTotal ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
