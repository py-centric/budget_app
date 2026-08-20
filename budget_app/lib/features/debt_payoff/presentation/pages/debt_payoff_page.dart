import 'package:flutter/material.dart';
import '../../domain/entities/debt_payoff_plan.dart';
import '../../domain/usecases/calculate_debt_payoff.dart';

class DebtPayoffPage extends StatefulWidget {
  const DebtPayoffPage({super.key});

  @override
  State<DebtPayoffPage> createState() => _DebtPayoffPageState();
}

class _DebtPayoffPageState extends State<DebtPayoffPage> {
  final _paymentController = TextEditingController(text: '500');
  PayoffStrategy _strategy = PayoffStrategy.snowball;
  final List<DebtInput> _debts = [
    const DebtInput(name: 'Credit Card', balance: 3000, apr: 22.99, minimumPayment: 60),
    const DebtInput(name: 'Car Loan', balance: 12000, apr: 5.9, minimumPayment: 250),
    const DebtInput(name: 'Student Loan', balance: 25000, apr: 4.5, minimumPayment: 300),
  ];
  DebtPayoffPlan? _plan;

  void _calculate() {
    final payment = double.tryParse(_paymentController.text) ?? 0;
    if (payment <= 0 || _debts.isEmpty) return;
    final calculator = CalculateDebtPayoff();
    setState(() {
      _plan = calculator(
        debts: _debts,
        monthlyPayment: payment,
        strategy: _strategy,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debt Payoff Planner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputSection(),
            const SizedBox(height: 16),
            _buildStrategySelector(),
            const SizedBox(height: 16),
            FilledButton(onPressed: _calculate, child: const Text('Calculate Payoff Plan')),
            if (_plan != null) ...[
              const SizedBox(height: 24),
              _buildResults(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Debts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _paymentController,
              decoration: const InputDecoration(labelText: 'Monthly Payment', prefixText: '\$'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategySelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Strategy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            RadioGroup<PayoffStrategy>(
              groupValue: _strategy,
              onChanged: (v) {
                if (v != null) {
                  setState(() => _strategy = v);
                }
              },
              child: const Column(
                children: [
                  RadioListTile<PayoffStrategy>(
                    title: Text('Debt Snowball'),
                    subtitle: Text('Pay smallest balance first'),
                    value: PayoffStrategy.snowball,
                  ),
                  RadioListTile<PayoffStrategy>(
                    title: Text('Debt Avalanche'),
                    subtitle: Text('Pay highest interest first'),
                    value: PayoffStrategy.avalanche,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _resultRow('Total Months', '${_plan!.totalMonths}'),
                _resultRow('Total Interest', '\$${_plan!.totalInterest.toStringAsFixed(2)}'),
                _resultRow('Total Paid', '\$${_plan!.totalPaid.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ..._plan!.debts.map((d) => Card(
              child: ListTile(
                title: Text(d.name),
                subtitle: Text('Payoff in ${d.monthsToPayoff} months'),
                trailing: Text('\$${d.interestPaid.toStringAsFixed(0)} interest',
                    style: const TextStyle(fontSize: 12)),
              ),
            )),
      ],
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))],
      ),
    );
  }

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }
}
