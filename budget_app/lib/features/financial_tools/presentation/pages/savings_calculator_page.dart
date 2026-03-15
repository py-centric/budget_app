import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/financial_bloc.dart';
import '../widgets/savings_chart.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../domain/usecases/calculate_amortization.dart';

class SavingsCalculatorPage extends StatefulWidget {
  const SavingsCalculatorPage({super.key});

  @override
  State<SavingsCalculatorPage> createState() => _SavingsCalculatorPageState();
}

class _SavingsCalculatorPageState extends State<SavingsCalculatorPage> {
  final _initialController = TextEditingController();
  final _monthlyController = TextEditingController();
  final _rateController = TextEditingController();
  final _yearsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<FinancialBloc>().state;
    _initialController.text = state.savingsInitial.toString();
    _monthlyController.text = state.savingsMonthly.toString();
    _rateController.text = state.savingsRate.toString();
    _yearsController.text = state.savingsYears.toString();
  }

  @override
  void dispose() {
    _initialController.dispose();
    _monthlyController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  void _update({InterestType? type}) {
    context.read<FinancialBloc>().add(UpdateSavingsParamsEvent(
      initial: double.tryParse(_initialController.text),
      monthly: double.tryParse(_monthlyController.text),
      rate: double.tryParse(_rateController.text),
      years: int.tryParse(_yearsController.text),
      interestType: type ?? context.read<FinancialBloc>().state.savingsInterestType,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = context.watch<SettingsBloc>().state.settings.currencyCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final TextEditingController nameController = TextEditingController(text: 'Savings Plan');
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Save Savings Plan'),
                  content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        context.read<FinancialBloc>().add(SaveCalculationEvent(name: nameController.text, type: 'SAVINGS'));
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<FinancialBloc, FinancialState>(
        builder: (context, state) {
          final schedule = context.read<FinancialBloc>().calculateCompoundInterest(
            initialDeposit: state.savingsInitial,
            monthlyContribution: state.savingsMonthly,
            annualRate: state.savingsRate,
            years: state.savingsYears,
            type: state.savingsInterestType,
          );
          final futureValue = context.read<FinancialBloc>().calculateCompoundInterest.calculateFutureValue(
            initialDeposit: state.savingsInitial,
            monthlyContribution: state.savingsMonthly,
            annualRate: state.savingsRate,
            years: state.savingsYears,
            type: state.savingsInterestType,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _initialController,
                              decoration: const InputDecoration(
                                labelText: 'Initial Deposit',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _update(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _monthlyController,
                              decoration: const InputDecoration(
                                labelText: 'Monthly Contribution',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _update(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _rateController,
                              decoration: const InputDecoration(
                                labelText: 'Annual Return (%)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _update(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _yearsController,
                              decoration: const InputDecoration(
                                labelText: 'Duration (Years)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _update(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<InterestType>(
                        segments: const [
                          ButtonSegment(value: InterestType.compound, label: Text('Compound')),
                          ButtonSegment(value: InterestType.simple, label: Text('Simple')),
                        ],
                        selected: {state.savingsInterestType},
                        onSelectionChanged: (Set<InterestType> newSelection) {
                          _update(type: newSelection.first);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text('Estimated Future Value'),
                      Text(
                        CurrencyFormatter.format(futureValue, currencyCode: currencyCode),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 250,
                child: SavingsChart(schedule: schedule),
              ),
            ],
          );
        },
      ),
    );
  }
}
