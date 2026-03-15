import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/projection_point.dart';
import '../../../../core/utils/chart_color_utils.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';

class ProjectionChart extends StatelessWidget {
  final List<ProjectionPoint> points;
  final bool isWeekly;
  final bool showPotential;

  const ProjectionChart({
    super.key,
    required this.points,
    required this.isWeekly,
    this.showPotential = true,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(child: Text('No data for projection.'));
    }

    final currencyCode = context.watch<SettingsBloc>().state.settings.currencyCode;

    // Prepare data
    final filteredPoints = isWeekly 
        ? points.where((p) => p.isWeekEnding || p == points.last).toList()
        : points;

    if (filteredPoints.isEmpty) {
      return const Center(child: Text('Not enough data to display chart.'));
    }

    double minActual = filteredPoints.map((p) => p.actualBalance).reduce((a, b) => a < b ? a : b);
    double maxActual = filteredPoints.map((p) => p.actualBalance).reduce((a, b) => a > b ? a : b);
    double minPotential = showPotential 
        ? filteredPoints.map((p) => p.potentialBalance).reduce((a, b) => a < b ? a : b)
        : minActual;
    double maxPotential = showPotential 
        ? filteredPoints.map((p) => p.potentialBalance).reduce((a, b) => a > b ? a : b)
        : maxActual;

    double minBalance = minActual < minPotential ? minActual : minPotential;
    double maxBalance = maxActual > maxPotential ? maxActual : maxPotential;
    
    // Add some padding to Y axis
    minBalance = minBalance < 0 ? minBalance * 1.1 : minBalance * 0.9;
    maxBalance = maxBalance > 0 ? maxBalance * 1.1 : maxBalance * 1.1;

    if (minBalance == maxBalance) {
      minBalance -= 100;
      maxBalance += 100;
    }

    final actualSpots = filteredPoints.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.actualBalance);
    }).toList();

    final potentialSpots = filteredPoints.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.potentialBalance);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: actualSpots.length.toDouble() - 1,
          minY: minBalance,
          maxY: maxBalance,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: (maxBalance - minBalance) / 5 == 0 ? 1 : (maxBalance - minBalance) / 5,
            verticalInterval: actualSpots.length > 5 ? (actualSpots.length / 5).floorToDouble() : 1,
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: actualSpots.length > 5 ? (actualSpots.length / 5).floorToDouble() : 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < filteredPoints.length) {
                    final date = filteredPoints[index].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('MM/dd').format(date),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (maxBalance - minBalance) / 5 == 0 ? 1 : (maxBalance - minBalance) / 5,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  return Text(
                    NumberFormat.compactSimpleCurrency(name: currencyCode).format(value),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: actualSpots,
              isCurved: true,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: actualSpots.length <= 30),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: ChartColorUtils.getSharpGradientColors(
                  positiveColor: Colors.green,
                  negativeColor: Colors.red,
                  minY: minBalance,
                  maxY: maxBalance,
                ),
                stops: ChartColorUtils.calculateSharpStops(
                  minY: minBalance,
                  maxY: maxBalance,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withValues(alpha: 0.1),
                applyCutOffY: true,
                cutOffY: 0,
              ),
              aboveBarData: BarAreaData(
                show: true,
                color: Colors.red.withValues(alpha: 0.1),
                applyCutOffY: true,
                cutOffY: 0,
              ),
            ),
            if (showPotential)
              LineChartBarData(
                spots: potentialSpots,
                isCurved: true,
                barWidth: 2,
                dashArray: [5, 5],
                color: Colors.blue.withValues(alpha: 0.6),
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
              ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final date = filteredPoints[spot.x.toInt()].date;
                  final formattedDate = DateFormat('MMM dd, yyyy').format(date);
                  final formattedBalance = CurrencyFormatter.format(spot.y, currencyCode: currencyCode);
                  final label = spot.barIndex == 0 ? 'Actual' : 'Potential';
                  return LineTooltipItem(
                    '$formattedDate\n$label: $formattedBalance',
                    TextStyle(color: spot.barIndex == 0 ? Colors.white : Colors.blue.shade100),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
