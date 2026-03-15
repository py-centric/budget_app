import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/amortization_point.dart';

class SavingsChart extends StatelessWidget {
  final List<AmortizationPoint> schedule;

  const SavingsChart({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    if (schedule.isEmpty) return const SizedBox.shrink();

    final List<AmortizationPoint> sampledPoints = schedule.length > 60
        ? schedule.asMap().entries
            .where((e) => e.key % (schedule.length / 12).floor() == 0 || e.key == schedule.length - 1)
            .map((e) => e.value)
            .toList()
        : schedule;

    final List<FlSpot> valueSpots = sampledPoints.map((p) {
      return FlSpot(p.month.toDouble(), p.remainingBalance);
    }).toList();

    final maxVal = schedule.last.remainingBalance;

    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 16),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: schedule.length.toDouble(),
          minY: 0,
          maxY: maxVal * 1.1,
          lineBarsData: [
            LineChartBarData(
              spots: valueSpots,
              isCurved: true,
              barWidth: 3,
              color: Colors.green,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withValues(alpha: 0.1),
              ),
              dotData: const FlDotData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              axisNameWidget: const Text('Months'),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: (schedule.length / 5).clamp(1, double.infinity),
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: const Text('Value'),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                interval: (maxVal / 5).clamp(1, double.infinity),
              ),
            ),
          ),
          gridData: const FlGridData(show: true, drawVerticalLine: true),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }
}
