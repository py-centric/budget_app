import 'package:flutter/material.dart';
import '../../domain/entities/tax_estimate.dart';
import '../../domain/usecases/calculate_tax.dart';

class TaxEstimationPage extends StatefulWidget {
  const TaxEstimationPage({super.key});

  @override
  State<TaxEstimationPage> createState() => _TaxEstimationPageState();
}

class _TaxEstimationPageState extends State<TaxEstimationPage> {
  final _incomeController = TextEditingController();
  final _deductionsController = TextEditingController();
  final _calculateTax = CalculateTax();
  TaxEstimate? _estimate;

  @override
  void dispose() {
    _incomeController.dispose();
    _deductionsController.dispose();
    super.dispose();
  }

  void _calculate() {
    final income = double.tryParse(_incomeController.text) ?? 0;
    final deductions = double.tryParse(_deductionsController.text) ?? 0;
    setState(() {
      _estimate = _calculateTax(income: income, deductions: deductions);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Estimation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _incomeController,
              decoration: const InputDecoration(
                labelText: 'Annual Income',
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _deductionsController,
              decoration: const InputDecoration(
                labelText: 'Deductions',
                prefixText: '\$',
                hintText: 'Standard deduction: \$14,600',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _calculate,
              child: const Text('Calculate'),
            ),
            if (_estimate != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Tax Estimate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Divider(),
                      _ResultRow(label: 'Gross Income', value: '\$${_estimate!.income.toStringAsFixed(2)}'),
                      _ResultRow(label: 'Deductions', value: '\$${_estimate!.deductions.toStringAsFixed(2)}'),
                      _ResultRow(label: 'Taxable Income', value: '\$${_estimate!.taxableIncome.toStringAsFixed(2)}'),
                      const Divider(),
                      _ResultRow(label: 'Total Tax', value: '\$${_estimate!.totalTax.toStringAsFixed(2)}', highlighted: true),
                      _ResultRow(label: 'Effective Rate', value: '${_estimate!.effectiveRate.toStringAsFixed(2)}%', highlighted: true),
                      const Divider(),
                      _ResultRow(label: 'Take Home', value: '\$${_estimate!.takeHome.toStringAsFixed(2)}', highlighted: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('2024 Tax Brackets', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _BracketRow(rate: '10%', range: 'Up to \$11,600'),
                      _BracketRow(rate: '12%', range: '\$11,601 - \$47,150'),
                      _BracketRow(rate: '22%', range: '\$47,151 - \$100,525'),
                      _BracketRow(rate: '24%', range: '\$100,526 - \$191,950'),
                      _BracketRow(rate: '32%', range: '\$191,951 - \$243,725'),
                      _BracketRow(rate: '35%', range: '\$243,726 - \$609,350'),
                      _BracketRow(rate: '37%', range: 'Above \$609,350'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlighted;

  const _ResultRow({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: highlighted ? FontWeight.bold : FontWeight.normal,
              color: highlighted ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _BracketRow extends StatelessWidget {
  final String rate;
  final String range;

  const _BracketRow({required this.rate, required this.range});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rate, style: const TextStyle(fontSize: 12)),
          Text(range, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
