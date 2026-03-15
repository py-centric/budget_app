import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/solve_interest_rate.dart';
import '../../domain/usecases/convert_rate.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';

class RateConverterPage extends StatefulWidget {
  const RateConverterPage({super.key});

  @override
  State<RateConverterPage> createState() => _RateConverterPageState();
}

class _RateConverterPageState extends State<RateConverterPage> {
  final _solverPrincipalController = TextEditingController(text: '10000');
  final _solverMonthsController = TextEditingController(text: '12');
  final _solverPaymentController = TextEditingController(text: '900');
  
  final _convSimpleController = TextEditingController(text: '10');
  final _convCompoundController = TextEditingController(text: '10.47');

  final _solver = InterestRateSolver();
  final _converter = RateConverter();

  double _solvedRate = 0;
  double _convertedCompound = 0;
  double _convertedSimple = 0;

  @override
  void initState() {
    super.initState();
    _solve();
    _convertSimple();
  }

  void _solve() {
    final p = double.tryParse(_solverPrincipalController.text) ?? 0;
    final n = int.tryParse(_solverMonthsController.text) ?? 0;
    final m = double.tryParse(_solverPaymentController.text) ?? 0;
    setState(() {
      _solvedRate = _solver.solve(principal: p, months: n, monthlyPayment: m);
    });
  }

  void _convertSimple() {
    final r = double.tryParse(_convSimpleController.text) ?? 0;
    setState(() {
      _convertedCompound = _converter.simpleToCompound(simpleRate: r);
    });
  }

  void _convertCompound() {
    final r = double.tryParse(_convCompoundController.text) ?? 0;
    setState(() {
      _convertedSimple = _converter.compoundToSimple(compoundRate: r);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = context.watch<SettingsBloc>().state.settings.currencyCode;

    return Scaffold(
      appBar: AppBar(title: const Text('Rate Converter & Solver')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSolverCard(currencyCode),
          const SizedBox(height: 24),
          _buildConverterCard(),
        ],
      ),
    );
  }

  Widget _buildSolverCard(String currencyCode) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Loan Interest Solver', style: Theme.of(context).textTheme.titleLarge),
            const Text('Find the effective rate of a loan.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: _solverPrincipalController,
              decoration: const InputDecoration(labelText: 'Principal Amount'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _solve(),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _solverMonthsController,
                    decoration: const InputDecoration(labelText: 'Term (Months)'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _solve(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _solverPaymentController,
                    decoration: const InputDecoration(labelText: 'Monthly Payment'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _solve(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text('Effective Annual Rate (Compounded Monthly)'),
                  Text(
                    '${_solvedRate.toStringAsFixed(2)}%',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConverterCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rate Converter', style: Theme.of(context).textTheme.titleLarge),
            const Text('Convert between Simple and Compound EAR.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: _convSimpleController,
              decoration: const InputDecoration(
                labelText: 'Simple Annual Rate (%)',
                suffixText: '→ Compound',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _convertSimple(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '= ${_convertedCompound.toStringAsFixed(4)}% EAR',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            const Divider(),
            TextField(
              controller: _convCompoundController,
              decoration: const InputDecoration(
                labelText: 'Compound EAR (%)',
                suffixText: '→ Simple',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _convertCompound(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '= ${_convertedSimple.toStringAsFixed(4)}% Simple',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
