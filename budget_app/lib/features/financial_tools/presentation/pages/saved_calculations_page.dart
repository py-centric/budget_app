import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/financial_bloc.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';

class SavedCalculationsPage extends StatefulWidget {
  const SavedCalculationsPage({super.key});

  @override
  State<SavedCalculationsPage> createState() => _SavedCalculationsPageState();
}

class _SavedCalculationsPageState extends State<SavedCalculationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<FinancialBloc>().add(const LoadSavedCalculationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = context.watch<SettingsBloc>().state.settings.currencyCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Items'),
      ),
      body: BlocBuilder<FinancialBloc, FinancialState>(
        builder: (context, state) {
          if (state.isLoading) return const Center(child: CircularProgressIndicator());
          if (state.savedCalculations.isEmpty) {
            return const Center(child: Text('No saved items yet.'));
          }

          return ListView.builder(
            itemCount: state.savedCalculations.length,
            itemBuilder: (context, index) {
              final item = state.savedCalculations[index];
              return Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  context.read<FinancialBloc>().add(DeleteSavedCalculationEvent(item.id));
                },
                child: ListTile(
                  leading: Icon(
                    item.type == 'NET_WORTH' ? Icons.account_balance_wallet :
                    item.type == 'LOAN' ? Icons.monetization_on : Icons.trending_up,
                    color: item.type == 'NET_WORTH' ? Colors.blue :
                           item.type == 'LOAN' ? Colors.red : Colors.green,
                  ),
                  title: Text(item.name),
                  subtitle: Text('${item.type} - ${DateFormat.yMMMd().format(item.createdAt)}'),
                  trailing: Text(
                    _getDisplayValue(item, currencyCode),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getDisplayValue(dynamic item, String currencyCode) {
    if (item.type == 'NET_WORTH') return CurrencyFormatter.format(item.data['total'] ?? 0, currencyCode: currencyCode);
    if (item.type == 'LOAN') return CurrencyFormatter.format(item.data['monthlyPayment'] ?? 0, currencyCode: currencyCode);
    if (item.type == 'SAVINGS') return CurrencyFormatter.format(item.data['futureValue'] ?? 0, currencyCode: currencyCode);
    return '';
  }
}
