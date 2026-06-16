import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/saved_calculation.dart';
import '../../../../core/utils/currency_formatter.dart';

class NetWorthChart extends StatelessWidget {
  final List<SavedCalculation> history;
  final String currencyCode;

  const NetWorthChart({
    super.key,
    required this.history,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    if (history.length < 2) {
      return const SizedBox.shrink();
    }

    final totals = history.map((e) => (e.data['total'] as num?)?.toDouble() ?? 0.0).toList();
    
    double peakValue = -double.infinity;
    double troughValue = double.infinity;
    int peakIndex = -1;
    int troughIndex = -1;

    for (int i = 0; i < totals.length; i++) {
      final val = totals[i];
      if (val > peakValue) {
        peakValue = val;
        peakIndex = i;
      }
      if (val < troughValue) {
        troughValue = val;
        troughIndex = i;
      }
    }

    final minTotal = totals.reduce(math.min);
    final maxTotal = totals.reduce(math.max);
    final range = maxTotal - minTotal;
    
    final minY = minTotal - (range > 0 ? range * 0.15 : 1000.0);
    final maxY = maxTotal + (range > 0 ? range * 0.15 : 1000.0);

    final List<FlSpot> spots = [];
    for (int i = 0; i < totals.length; i++) {
      spots.add(FlSpot(i.toDouble(), totals[i]));
    }

    final isSingleValueRange = range == 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Net Worth Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, left: 4),
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (totals.length - 1).toDouble(),
                    minY: minY,
                    maxY: maxY,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedBarSpot) =>
                            Theme.of(context).colorScheme.secondaryContainer,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final idx = spot.x.toInt();
                            if (idx < 0 || idx >= history.length) return null;
                            final calc = history[idx];
                            final dateStr = DateFormat.yMMMd().format(calc.createdAt);
                            final prefix = idx == peakIndex
                                ? '📈 Peak\n'
                                : idx == troughIndex
                                    ? '📉 Trough\n'
                                    : '';
                            return LineTooltipItem(
                              '$prefix${calc.name}\n${CurrencyFormatter.format(spot.y, currencyCode: currencyCode)}\n$dateStr',
                              TextStyle(
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: totals.length > 2,
                        curveSmoothness: 0.35,
                        barWidth: 3.5,
                        color: Theme.of(context).colorScheme.primary,
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            final idx = spot.x.toInt();
                            if (idx == peakIndex && !isSingleValueRange) {
                              return FlDotCirclePainter(
                                radius: 7,
                                color: Colors.green,
                                strokeWidth: 2.5,
                                strokeColor: Colors.white,
                              );
                            } else if (idx == troughIndex && !isSingleValueRange) {
                              return FlDotCirclePainter(
                                radius: 7,
                                color: Colors.red,
                                strokeWidth: 2.5,
                                strokeColor: Colors.white,
                              );
                            }
                            return FlDotCirclePainter(
                              radius: 4.5,
                              color: Theme.of(context).colorScheme.primary,
                              strokeWidth: 1.5,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: math.max(1, (totals.length / 5).floor()).toDouble(),
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx >= 0 && idx < history.length) {
                              final date = history[idx].createdAt;
                              return SideTitleWidget(
                                meta: meta,
                                child: Text(
                                  DateFormat('MM/dd').format(date),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 52,
                          interval: isSingleValueRange
                              ? 1000.0
                              : math.max(1.0, range / 4),
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                _formatCompactValue(value),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 9,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withValues(alpha: 0.15),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                        left: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (!isSingleValueRange) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem(
                    context,
                    icon: Icons.trending_up,
                    color: Colors.green,
                    label: 'Peak',
                    value: CurrencyFormatter.format(peakValue, currencyCode: currencyCode),
                  ),
                  _buildLegendItem(
                    context,
                    icon: Icons.trending_down,
                    color: Colors.red,
                    label: 'Trough',
                    value: CurrencyFormatter.format(troughValue, currencyCode: currencyCode),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatCompactValue(double value) {
    final absVal = value.abs();
    final sign = value < 0 ? '-' : '';
    if (absVal >= 1000000) {
      return '$sign\$${(absVal / 1000000).toStringAsFixed(1)}M';
    } else if (absVal >= 1000) {
      return '$sign\$${(absVal / 1000).toStringAsFixed(0)}K';
    } else {
      return '$sign\$${absVal.toStringAsFixed(0)}';
    }
  }
}
