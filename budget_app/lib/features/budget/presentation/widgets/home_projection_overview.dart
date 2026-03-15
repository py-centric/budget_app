import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bloc/projection_bloc.dart';
import '../bloc/projection_event.dart';
import '../bloc/projection_state.dart';
import '../pages/projection_page.dart';
import '../../../../core/utils/chart_color_utils.dart';

class HomeProjectionOverview extends StatefulWidget {
  const HomeProjectionOverview({super.key});

  @override
  State<HomeProjectionOverview> createState() => _HomeProjectionOverviewState();
}

class _HomeProjectionOverviewState extends State<HomeProjectionOverview> {
  final List<String> _horizons = ['MONTH', '7_DAYS', '30_DAYS'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectionBloc, ProjectionState>(
      builder: (context, state) {
        if (state is ProjectionLoading || state is ProjectionInitial) {
          return const Card(
            child: SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (state is ProjectionError) {
          return Card(
            child: SizedBox(
              height: 200,
              child: Center(child: Text('Error: ${state.message}')),
            ),
          );
        }

        if (state is ProjectionLoaded) {
          // Find index of current horizon
          int currentPage = _horizons.indexOf(state.settings.defaultProjectionHorizon);
          if (currentPage == -1) currentPage = 0;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProjectionPage()),
              );
            },
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Projection Overview',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child: PageView.builder(
                        controller: PageController(initialPage: currentPage),
                        onPageChanged: (index) {
                          context
                              .read<ProjectionBloc>()
                              .add(ChangeProjectionHorizon(_horizons[index]));
                        },
                        itemCount: _horizons.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Text(
                                _getHorizonLabel(_horizons[index]),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: _buildMiniChart(context, state),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _horizons.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentPage == index
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  String _getHorizonLabel(String horizon) {
    switch (horizon) {
      case 'MONTH':
        return 'Current Month';
      case '7_DAYS':
        return 'Rolling 7 Days';
      case '30_DAYS':
        return 'Rolling 30 Days';
      default:
        return horizon;
    }
  }

  Widget _buildMiniChart(BuildContext context, ProjectionLoaded state) {
    if (state.points.isEmpty) {
      return const Center(child: Text('No data'));
    }

    final spots = state.points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.balance);
    }).toList();

    double minBalance = state.points.map((p) => p.balance).reduce((a, b) => a < b ? a : b);
    double maxBalance = state.points.map((p) => p.balance).reduce((a, b) => a > b ? a : b);

    // Add padding
    double padding = (maxBalance - minBalance) * 0.1;
    if (padding == 0) padding = 100;
    minBalance -= padding;
    maxBalance += padding;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: spots.length.toDouble() - 1,
        minY: minBalance,
        maxY: maxBalance,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
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
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }
}
