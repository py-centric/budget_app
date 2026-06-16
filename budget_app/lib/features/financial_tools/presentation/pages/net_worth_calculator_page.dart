import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/financial_bloc.dart';
import '../../domain/entities/financial_tool_entry.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../widgets/net_worth_chart.dart';

class NetWorthCalculatorPage extends StatefulWidget {
  const NetWorthCalculatorPage({super.key});

  @override
  State<NetWorthCalculatorPage> createState() => _NetWorthCalculatorPageState();
}

class _NetWorthCalculatorPageState extends State<NetWorthCalculatorPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FinancialBloc>().add(const LoadSavedCalculationsEvent());
  }

  void _addEntry(bool isAsset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAsset ? 'Add Asset' : 'Add Liability'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name (e.g. Cash, Loan)',
              ),
            ),
            TextField(
              controller: _valueController,
              decoration: const InputDecoration(labelText: 'Value'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(_valueController.text) ?? 0;
              if (_nameController.text.isNotEmpty) {
                final entry = FinancialToolEntry(
                  label: _nameController.text,
                  value: val,
                );
                final bloc = context.read<FinancialBloc>();
                if (isAsset) {
                  bloc.add(
                    UpdateNetWorthAssetsEvent([
                      ...bloc.state.netWorthAssets,
                      entry,
                    ]),
                  );
                } else {
                  bloc.add(
                    UpdateNetWorthLiabilitiesEvent([
                      ...bloc.state.netWorthLiabilities,
                      entry,
                    ]),
                  );
                }
                _nameController.clear();
                _valueController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _saveSnapshot() {
    final TextEditingController snapshotNameController = TextEditingController(
      text: 'Snapshot ${DateTime.now().toString().split('.')[0]}',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Net Worth Snapshot'),
        content: TextField(
          controller: snapshotNameController,
          decoration: const InputDecoration(labelText: 'Snapshot Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<FinancialBloc>().add(
                SaveCalculationEvent(
                  name: snapshotNameController.text,
                  type: 'NET_WORTH',
                ),
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Snapshot saved successfully!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = context
        .watch<SettingsBloc>()
        .state
        .settings
        .currencyCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Net Worth Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSnapshot,
            tooltip: 'Save Snapshot',
          ),
        ],
      ),
      body: BlocBuilder<FinancialBloc, FinancialState>(
        builder: (context, state) {
          final netWorthHistory = state.savedCalculations
              .where((calc) => calc.type == 'NET_WORTH')
              .toList()
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'Total Net Worth',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(
                          state.netWorth,
                          currencyCode: currencyCode,
                        ),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (netWorthHistory.length >= 2) ...[
                NetWorthChart(
                  history: netWorthHistory,
                  currencyCode: currencyCode,
                ),
              ] else ...[
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Track Your Net Worth Over Time',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Save at least 2 snapshots using the save icon at the top to generate your historical trend chart showing peaks and troughs.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Assets',
                state.netWorthAssets,
                Colors.green,
                () => _addEntry(true),
                (index) {
                  final list = List<FinancialToolEntry>.from(
                    state.netWorthAssets,
                  )..removeAt(index);
                  context.read<FinancialBloc>().add(
                    UpdateNetWorthAssetsEvent(list),
                  );
                },
                currencyCode,
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Liabilities',
                state.netWorthLiabilities,
                Colors.red,
                () => _addEntry(false),
                (index) {
                  final list = List<FinancialToolEntry>.from(
                    state.netWorthLiabilities,
                  )..removeAt(index);
                  context.read<FinancialBloc>().add(
                    UpdateNetWorthLiabilitiesEvent(list),
                  );
                },
                currencyCode,
              ),
              if (netWorthHistory.isNotEmpty) ...[
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Snapshot History',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${netWorthHistory.length} Saved',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const Divider(),
                ...netWorthHistory.reversed.map((snapshot) {
                  final total = (snapshot.data['total'] as num?)?.toDouble() ?? 0.0;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    title: Text(snapshot.name),
                    subtitle: Text(
                      DateFormat('MMM d, yyyy • h:mm a').format(snapshot.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          CurrencyFormatter.format(total, currencyCode: currencyCode),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          onPressed: () {
                            context.read<FinancialBloc>().add(
                              DeleteSavedCalculationEvent(snapshot.id),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<FinancialToolEntry> entries,
    Color color,
    VoidCallback onAdd,
    Function(int) onDelete,
    String currencyCode,
  ) {
    final total = entries.fold<double>(0, (sum, e) => sum + e.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$title (${CurrencyFormatter.format(total, currencyCode: currencyCode)})',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: color),
            ),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_outline),
              color: color,
            ),
          ],
        ),
        const Divider(),
        if (entries.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'No items added yet.',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ),
        ...entries.asMap().entries.map((entry) {
          return ListTile(
            title: Text(entry.value.label),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  CurrencyFormatter.format(
                    entry.value.value,
                    currencyCode: currencyCode,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => onDelete(entry.key),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
