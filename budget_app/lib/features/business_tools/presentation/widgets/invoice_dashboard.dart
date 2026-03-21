import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/invoice_summary.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class InvoiceDashboard extends StatelessWidget {
  final InvoiceSummary summary;
  final DateTimeRange? filterRange;
  final Function(DateTimeRange) onRangeChanged;

  const InvoiceDashboard({
    super.key,
    required this.summary,
    this.filterRange,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                context,
                'Receivables',
                summary.totalReceivables,
                Colors.green,
              ),
              _buildStatCard(
                context,
                'Payables',
                summary.totalPayables,
                Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 120,
                  child: _buildPieChart(),
                ),
              ),
              Expanded(
                flex: 3,
                child: _buildLegend(),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _selectRange(context),
              ),
            ],
          ),
          if (filterRange != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Period: ${DateFormat('MMM dd').format(filterRange!.start)} - ${DateFormat('MMM dd').format(filterRange!.end)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, double amount, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.format(amount),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final total = summary.paidCount + summary.unpaidCount + summary.partialCount;
    if (total == 0) {
      return const Center(child: Text('No data'));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        sections: [
          PieChartSectionData(
            value: summary.paidCount.toDouble(),
            color: Colors.green,
            title: '',
            radius: 15,
          ),
          PieChartSectionData(
            value: summary.unpaidCount.toDouble(),
            color: Colors.red,
            title: '',
            radius: 15,
          ),
          PieChartSectionData(
            value: summary.partialCount.toDouble(),
            color: Colors.orange,
            title: '',
            radius: 15,
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: Colors.green, label: 'Paid (${summary.paidCount})'),
        _LegendItem(color: Colors.red, label: 'Unpaid (${summary.unpaidCount})'),
        _LegendItem(color: Colors.orange, label: 'Partial (${summary.partialCount})'),
      ],
    );
  }

  Future<void> _selectRange(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: filterRange,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (range != null) {
      onRangeChanged(range);
    }
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
