import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/financial_health_bloc.dart';
import '../bloc/financial_health_event.dart';
import '../bloc/financial_health_state.dart';
import '../../domain/entities/financial_health_score.dart';

class FinancialHealthPage extends StatefulWidget {
  const FinancialHealthPage({super.key});

  @override
  State<FinancialHealthPage> createState() => _FinancialHealthPageState();
}

class _FinancialHealthPageState extends State<FinancialHealthPage> {
  final _incomeController = TextEditingController(text: '3000');
  final _expenseController = TextEditingController(text: '2000');
  final _debtController = TextEditingController(text: '5000');
  final _savingsController = TextEditingController(text: '10000');

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final income = double.tryParse(_incomeController.text) ?? 0;
    final expenses = double.tryParse(_expenseController.text) ?? 0;
    final debt = double.tryParse(_debtController.text) ?? 0;
    final savings = double.tryParse(_savingsController.text) ?? 0;
    context.read<FinancialHealthBloc>().add(CalculateHealthScore(
      monthlyIncome: income,
      monthlyExpenses: expenses,
      totalDebt: debt,
      totalSavings: savings,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Health')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputSection(),
            const SizedBox(height: 24),
            BlocBuilder<FinancialHealthBloc, FinancialHealthState>(
              builder: (context, state) {
                if (state is FinancialHealthLoaded) {
                  return _buildResults(state.score);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
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
            const Text('Monthly Finances', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _incomeController,
              decoration: const InputDecoration(labelText: 'Monthly Income', prefixText: '\$'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _expenseController,
              decoration: const InputDecoration(labelText: 'Monthly Expenses', prefixText: '\$'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _debtController,
              decoration: const InputDecoration(labelText: 'Total Debt', prefixText: '\$'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _savingsController,
              decoration: const InputDecoration(labelText: 'Total Savings', prefixText: '\$'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculate(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(FinancialHealthScore score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildScoreCard(score),
        const SizedBox(height: 16),
        _buildMetricCard('Savings Rate', '${score.savingsRate.toStringAsFixed(1)}%', score.savingsRateGrade,
            'Aim for 20%+ of income'),
        _buildMetricCard('Debt-to-Income', '${score.debtToIncomeRatio.toStringAsFixed(1)}%', score.debtToIncomeGrade,
            'Keep below 36%'),
        _buildMetricCard('Emergency Fund', '${score.emergencyFundMonths.toStringAsFixed(1)} months', score.emergencyFundGrade,
            'Aim for 6+ months of expenses'),
      ],
    );
  }

  Widget _buildScoreCard(FinancialHealthScore score) {
    final color = _gradeColor(score.overallGrade);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Text(
                '${score.overallScore}',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color),
              ),
              Text(
                _gradeLabel(score.overallGrade),
                style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              const Text('Overall Financial Health', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, HealthMetricType grade, String hint) {
    final color = _gradeColor(grade);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(_gradeIcon(grade), color: color, size: 20),
        ),
        title: Text(title),
        subtitle: Text(hint, style: const TextStyle(fontSize: 12)),
        trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
      ),
    );
  }

  Color _gradeColor(HealthMetricType grade) {
    switch (grade) {
      case HealthMetricType.excellent:
        return Colors.green;
      case HealthMetricType.good:
        return Colors.blue;
      case HealthMetricType.fair:
        return Colors.orange;
      case HealthMetricType.poor:
        return Colors.red;
    }
  }

  IconData _gradeIcon(HealthMetricType grade) {
    switch (grade) {
      case HealthMetricType.excellent:
        return Icons.star;
      case HealthMetricType.good:
        return Icons.thumb_up;
      case HealthMetricType.fair:
        return Icons.warning;
      case HealthMetricType.poor:
        return Icons.error;
    }
  }

  String _gradeLabel(HealthMetricType grade) {
    switch (grade) {
      case HealthMetricType.excellent:
        return 'Excellent';
      case HealthMetricType.good:
        return 'Good';
      case HealthMetricType.fair:
        return 'Fair';
      case HealthMetricType.poor:
        return 'Needs Improvement';
    }
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _expenseController.dispose();
    _debtController.dispose();
    _savingsController.dispose();
    super.dispose();
  }
}
