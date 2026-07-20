import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../budget/domain/repositories/budget_repository.dart';
import '../../domain/entities/spending_trend.dart';
import '../../domain/usecases/calculate_spending_trends.dart';

class SpendingTrendsPage extends StatefulWidget {
  const SpendingTrendsPage({super.key});

  // TODO: Custom date range — Add date range picker to allow users to select
  // a custom analysis period instead of the fixed 12-month window. Wire the
  // selected range into CalculateSpendingTrends(months: ...).
  @override
  State<SpendingTrendsPage> createState() => _SpendingTrendsPageState();
}

class _SpendingTrendsPageState extends State<SpendingTrendsPage> {
  List<SpendingTrend>? _trends;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTrends();
  }

  Future<void> _loadTrends() async {
    final repo = context.read<BudgetRepository>();
    final useCase = CalculateSpendingTrends(repo);
    final trends = await useCase(months: 12);
    if (mounted) {
      setState(() {
        _trends = trends;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spending Trends')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _trends == null || _trends!.isEmpty
              ? const Center(child: Text('No spending data available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _trends!.length,
                  itemBuilder: (context, index) {
                    final trend = _trends![index];
                    final trendColor = trend.trendPercentage > 0 ? Colors.red : Colors.green;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(trend.categoryName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(
                                  '${trend.trendPercentage > 0 ? '+' : ''}${trend.trendPercentage.toStringAsFixed(1)}%',
                                  style: TextStyle(color: trendColor, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Text('Avg: \$${trend.averageMonthly.toStringAsFixed(2)}/mo',
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 80,
                              child: BarChart(
                                BarChartData(
                                  barGroups: trend.monthlyData.asMap().entries.map((entry) {
                                    return BarChartGroupData(
                                      x: entry.key,
                                      barRods: [
                                        BarChartRodData(
                                          toY: entry.value.amount,
                                          color: Theme.of(context).colorScheme.primary,
                                          width: 8,
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                  titlesData: const FlTitlesData(show: false),
                                  borderData: FlBorderData(show: false),
                                  gridData: const FlGridData(show: false),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
