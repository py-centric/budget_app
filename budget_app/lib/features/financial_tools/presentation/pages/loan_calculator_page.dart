import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/financial_bloc.dart';
import '../widgets/amortization_chart.dart';
import '../widgets/amortization_schedule_table.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../domain/usecases/calculate_amortization.dart';

class LoanCalculatorPage extends StatefulWidget {
  const LoanCalculatorPage({super.key});

  @override
  State<LoanCalculatorPage> createState() => _LoanCalculatorPageState();
}

class _LoanCalculatorPageState extends State<LoanCalculatorPage> {
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _yearsController = TextEditingController();
  final _extraPaymentController = TextEditingController(text: '0');
  bool _showTable = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<FinancialBloc>().state;
    _principalController.text = state.loanPrincipal.toString();
    _rateController.text = state.loanRate.toString();
    _yearsController.text = state.loanYears.toString();
  }

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    _extraPaymentController.dispose();
    super.dispose();
  }

  void _update({InterestType? type}) {
    context.read<FinancialBloc>().add(UpdateLoanParamsEvent(
      principal: double.tryParse(_principalController.text),
      rate: double.tryParse(_rateController.text),
      years: int.tryParse(_yearsController.text),
      interestType: type ?? context.read<FinancialBloc>().state.loanInterestType,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = context.watch<SettingsBloc>().state.settings.currencyCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final TextEditingController nameController = TextEditingController(text: 'Loan ${_principalController.text}');
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Save Loan'),
                  content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        context.read<FinancialBloc>().add(SaveCalculationEvent(name: nameController.text, type: 'LOAN'));
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
          final schedule = context.read<FinancialBloc>().calculateAmortization(
            principal: state.loanPrincipal,
            annualRate: state.loanRate,
            years: state.loanYears,
            type: state.loanInterestType,
          );
          final monthlyPayment = context.read<FinancialBloc>().calculateAmortization.calculateMonthlyPayment(
            principal: state.loanPrincipal,
            annualRate: state.loanRate,
            years: state.loanYears,
            type: state.loanInterestType,
          );

          final extraMonthly = double.tryParse(_extraPaymentController.text) ?? 0;
          final totalMonthly = monthlyPayment + extraMonthly;
          
          final int reducedMonths = context.read<FinancialBloc>().calculateAmortization.calculateReducedTerm(
            principal: state.loanPrincipal,
            annualRate: state.loanRate,
            monthlyPayment: totalMonthly,
          );
          
          final int originalMonths = state.loanYears * 12;
          final int monthsSaved = originalMonths - reducedMonths;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _principalController,
                        decoration: const InputDecoration(
                          labelText: 'Principal Amount',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _update(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _rateController,
                              decoration: const InputDecoration(
                                labelText: 'Interest Rate (%)',
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
                                labelText: 'Term (Years)',
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
                        selected: {state.loanInterestType},
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
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text('Standard Monthly Payment'),
                      Text(
                        CurrencyFormatter.format(monthlyPayment, currencyCode: currencyCode),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payoff Projection', style: Theme.of(context).textTheme.titleMedium),
                      const Text('See how extra payments reduce your term.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _extraPaymentController,
                        decoration: const InputDecoration(
                          labelText: 'Extra Monthly Payment',
                          border: OutlineInputBorder(),
                          prefixText: '+ ',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                      if (extraMonthly > 0) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined, color: Colors.green),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'New Term: $reducedMonths months',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                    ),
                                    if (monthsSaved > 0)
                                      Text(
                                        'You save $monthsSaved months! (${(monthsSaved / 12).toStringAsFixed(1)} years)',
                                        style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: AmortizationChart(schedule: schedule),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Detailed Schedule', style: Theme.of(context).textTheme.titleMedium),
                  Switch(value: _showTable, onChanged: (v) => setState(() => _showTable = v)),
                ],
              ),
              if (_showTable)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: AmortizationScheduleTable(schedule: schedule, currencyCode: currencyCode),
                ),
            ],
          );
        },
      ),
    );
  }
}
