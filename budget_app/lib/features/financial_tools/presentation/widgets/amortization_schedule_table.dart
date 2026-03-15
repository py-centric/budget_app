import 'package:flutter/material.dart';
import '../../domain/entities/amortization_point.dart';
import '../../../../core/utils/currency_formatter.dart';

class AmortizationScheduleTable extends StatelessWidget {
  final List<AmortizationPoint> schedule;
  final String currencyCode;

  const AmortizationScheduleTable({
    super.key,
    required this.schedule,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columnSpacing: 12,
      columns: const [
        DataColumn(label: Text('Mo')),
        DataColumn(label: Text('Principal')),
        DataColumn(label: Text('Interest')),
        DataColumn(label: Text('Balance')),
      ],
      rows: schedule.map((p) {
        return DataRow(cells: [
          DataCell(Text(p.month.toString())),
          DataCell(Text(CurrencyFormatter.format(p.principalPaid, currencyCode: currencyCode))),
          DataCell(Text(CurrencyFormatter.format(p.interestPaid, currencyCode: currencyCode))),
          DataCell(Text(CurrencyFormatter.format(p.remainingBalance, currencyCode: currencyCode))),
        ]);
      }).toList(),
    );
  }
}
