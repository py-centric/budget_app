import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';

class ListHeaderTotal extends StatelessWidget {
  final String label;
  final double actualTotal;
  final double? potentialTotal;

  const ListHeaderTotal({
    super.key,
    required this.label,
    required this.actualTotal,
    this.potentialTotal,
  });

  @override
  Widget build(BuildContext context) {
    final currencyCode = context.watch<SettingsBloc>().state.settings.currencyCode;
    final showPotential = potentialTotal != null && (potentialTotal! - actualTotal).abs() > 0.01;

    return Row(
      children: [
        Text(label),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(actualTotal, currencyCode: currencyCode),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (showPotential)
              Text(
                'Pot: ${CurrencyFormatter.format(potentialTotal!, currencyCode: currencyCode)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
