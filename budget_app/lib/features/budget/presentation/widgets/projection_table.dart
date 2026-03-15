import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/projection_point.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/recurrence_calculator.dart';
import 'package:intl/intl.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';

class ProjectionTable extends StatelessWidget {
  final List<ProjectionPoint> points;
  final bool isWeekly;
  final Function(RecurringInstance instance, DateTime originalDate)? onEditInstance;

  const ProjectionTable({
    super.key,
    required this.points,
    required this.isWeekly,
    this.onEditInstance,
  });

  @override
  Widget build(BuildContext context) {
    final displayData = _prepareData();
    final currencyCode = context.watch<SettingsBloc>().state.settings.currencyCode;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Actual')),
            DataColumn(label: Text('Potential')),
            DataColumn(label: Text('Recurring')),
          ],
          rows: displayData.map((data) {
            return DataRow(cells: [
              DataCell(Text(data.dateLabel)),
              DataCell(Text(
                CurrencyFormatter.format(data.actualBalance, currencyCode: currencyCode),
                style: TextStyle(
                  color: data.actualBalance < 0 ? Colors.red : null,
                ),
              )),
              DataCell(Text(
                CurrencyFormatter.format(data.potentialBalance, currencyCode: currencyCode),
                style: TextStyle(
                  color: data.potentialBalance < 0 ? Colors.red : Colors.blue.shade700,
                  fontStyle: FontStyle.italic,
                ),
              )),
              DataCell(
                data.hasRecurring
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: data.recurringSummary,
                            child: const Icon(Icons.repeat, size: 16, color: Colors.blue),
                          ),
                          if (!isWeekly && onEditInstance != null)
                            IconButton(
                              icon: const Icon(Icons.edit, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                final point = points.firstWhere((p) => p.date == data.originalDate);
                                if (point.recurringInstances.isNotEmpty) {
                                  onEditInstance!(point.recurringInstances.first, data.originalDate!);
                                }
                              },
                            ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  List<_TableRowData> _prepareData() {
    if (points.isEmpty) return [];

    if (!isWeekly) {
      final formatter = DateFormat('MMM dd, yyyy');
      return points.map((p) => _TableRowData(
        dateLabel: formatter.format(p.date),
        originalDate: p.date,
        netChangeActual: p.netChangeActual,
        actualBalance: p.actualBalance,
        potentialBalance: p.potentialBalance,
        hasRecurring: p.recurringInstances.isNotEmpty,
        recurringSummary: p.recurringInstances.map((i) => i.description).join(', '),
      )).toList();
    }

    // Weekly aggregation
    final List<_TableRowData> aggregated = [];
    double weeklyNetChangeActual = 0;
    DateTime? weekStart = points.first.date;
    final Set<String> recurringDescriptions = {};

    for (var p in points) {
      weeklyNetChangeActual += p.netChangeActual;
      weekStart ??= p.date;
      for (final instance in p.recurringInstances) {
        recurringDescriptions.add(instance.description);
      }
      
      if (p.isWeekEnding || p == points.last) {
        final formatter = DateFormat('MMM dd');
        final label = '${formatter.format(weekStart)} - ${formatter.format(p.date)}';
        aggregated.add(_TableRowData(
          dateLabel: label,
          originalDate: null, // No single date for weekly
          netChangeActual: weeklyNetChangeActual,
          actualBalance: p.actualBalance,
          potentialBalance: p.potentialBalance,
          hasRecurring: recurringDescriptions.isNotEmpty,
          recurringSummary: recurringDescriptions.join(', '),
        ));
        weeklyNetChangeActual = 0;
        weekStart = null; 
        recurringDescriptions.clear();
      }
    }

    return aggregated;
  }
}

class _TableRowData {
  final String dateLabel;
  final DateTime? originalDate;
  final double netChangeActual;
  final double actualBalance;
  final double potentialBalance;
  final bool hasRecurring;
  final String recurringSummary;

  _TableRowData({
    required this.dateLabel,
    this.originalDate,
    required this.netChangeActual,
    required this.actualBalance,
    required this.potentialBalance,
    required this.hasRecurring,
    required this.recurringSummary,
  });
}
