import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bloc/net_worth_bloc.dart';
import '../bloc/net_worth_event.dart';
import '../bloc/net_worth_state.dart';

class NetWorthPage extends StatefulWidget {
  const NetWorthPage({super.key});

  @override
  State<NetWorthPage> createState() => _NetWorthPageState();
}

class _NetWorthPageState extends State<NetWorthPage> {
  @override
  void initState() {
    super.initState();
    context.read<NetWorthBloc>().add(const LoadNetWorthSnapshots());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Net Worth Over Time')),
      body: BlocBuilder<NetWorthBloc, NetWorthState>(
        builder: (context, state) {
          if (state is NetWorthLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentNetWorth(state.currentNetWorth),
                  const SizedBox(height: 24),
                  if (state.snapshots.isNotEmpty) ...[
                    const Text('Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(height: 200, child: _buildChart(state)),
                  ] else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No snapshots yet. Tap + to record your first net worth.'),
                      ),
                    ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSnapshotDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCurrentNetWorth(double netWorth) {
    final color = netWorth >= 0 ? Colors.green : Colors.red;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              const Text('Current Net Worth', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text(
                '\$${netWorth.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(NetWorthLoaded state) {
    final spots = <FlSpot>[];
    final reversed = state.snapshots.reversed.toList();
    for (var i = 0; i < reversed.length; i++) {
      spots.add(FlSpot(i.toDouble(), reversed[i].netWorth));
    }
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withAlpha(30),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSnapshotDialog() {
    final assetsController = TextEditingController();
    final liabilitiesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Net Worth'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: assetsController,
              decoration: const InputDecoration(labelText: 'Total Assets', prefixText: '\$'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: liabilitiesController,
              decoration: const InputDecoration(labelText: 'Total Liabilities', prefixText: '\$'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final assets = double.tryParse(assetsController.text) ?? 0;
              final liabilities = double.tryParse(liabilitiesController.text) ?? 0;
              context.read<NetWorthBloc>().add(AddNetWorthSnapshotEvent(
                totalAssets: assets,
                totalLiabilities: liabilities,
              ));
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
