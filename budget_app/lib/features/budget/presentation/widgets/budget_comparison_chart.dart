import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/budget_comparison.dart';

class BudgetComparisonChart extends StatelessWidget {
  final List<BudgetComparison> comparisons;

  const BudgetComparisonChart({super.key, required this.comparisons});

  @override
  Widget build(BuildContext context) {
    if (comparisons.isEmpty) {
      return const Center(child: Text('No budget data to display'));
    }

    final topComparisons = comparisons.take(6).toList();

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _calculateMaxY(topComparisons),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final comparison = topComparisons[groupIndex];
                final label = rodIndex == 0 ? 'Planned' : 'Actual';
                final value = rodIndex == 0
                    ? comparison.plannedAmount
                    : comparison.actualAmount;
                return BarTooltipItem(
                  '${comparison.categoryName}\n$label: \$${value.toStringAsFixed(0)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= topComparisons.length) {
                    return const SizedBox();
                  }
                  final categoryName =
                      topComparisons[value.toInt()].categoryName;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      categoryName.length > 8
                          ? '${categoryName.substring(0, 6)}...'
                          : categoryName,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
                reservedSize: 32,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _calculateInterval(topComparisons),
          ),
          barGroups: _generateBarGroups(topComparisons),
        ),
      ),
    );
  }

  double _calculateMaxY(List<BudgetComparison> comparisons) {
    double max = 0;
    for (final c in comparisons) {
      if (c.plannedAmount > max) max = c.plannedAmount;
      if (c.actualAmount > max) max = c.actualAmount;
    }
    return max * 1.2;
  }

  double _calculateInterval(List<BudgetComparison> comparisons) {
    final max = _calculateMaxY(comparisons);
    if (max <= 100) return 20;
    if (max <= 500) return 100;
    if (max <= 1000) return 200;
    return max / 5;
  }

  List<BarChartGroupData> _generateBarGroups(
    List<BudgetComparison> comparisons,
  ) {
    return comparisons.asMap().entries.map((entry) {
      final index = entry.key;
      final comparison = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: comparison.plannedAmount,
            color: Colors.blue.withValues(alpha: 0.7),
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          BarChartRodData(
            toY: comparison.actualAmount,
            color: comparison.isOverBudget
                ? Colors.red.withValues(alpha: 0.9)
                : Colors.green.withValues(alpha: 0.9),
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }
}

class BudgetComparisonLegend extends StatelessWidget {
  const BudgetComparisonLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: Colors.blue.withValues(alpha: 0.7),
          label: 'Planned',
        ),
        const SizedBox(width: 24),
        _LegendItem(color: Colors.green, label: 'Under Budget'),
        const SizedBox(width: 24),
        _LegendItem(color: Colors.red, label: 'Over Budget'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
