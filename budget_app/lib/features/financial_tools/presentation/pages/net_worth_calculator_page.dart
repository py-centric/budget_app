import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/financial_bloc.dart';
import '../../domain/entities/financial_tool_entry.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';

class NetWorthCalculatorPage extends StatefulWidget {
  const NetWorthCalculatorPage({super.key});

  @override
  State<NetWorthCalculatorPage> createState() => _NetWorthCalculatorPageState();
}

class _NetWorthCalculatorPageState extends State<NetWorthCalculatorPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

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
              decoration: const InputDecoration(labelText: 'Name (e.g. Cash, Loan)'),
            ),
            TextField(
              controller: _valueController,
              decoration: const InputDecoration(labelText: 'Value'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(_valueController.text) ?? 0;
              if (_nameController.text.isNotEmpty) {
                final entry = FinancialToolEntry(label: _nameController.text, value: val);
                final bloc = context.read<FinancialBloc>();
                if (isAsset) {
                  bloc.add(UpdateNetWorthAssetsEvent([...bloc.state.netWorthAssets, entry]));
                } else {
                  bloc.add(UpdateNetWorthLiabilitiesEvent([...bloc.state.netWorthLiabilities, entry]));
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<FinancialBloc>().add(SaveCalculationEvent(
                name: snapshotNameController.text,
                type: 'NET_WORTH',
              ));
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
    final currencyCode = context.watch<SettingsBloc>().state.settings.currencyCode;

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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text('Total Net Worth', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(state.netWorth, currencyCode: currencyCode),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Assets',
                state.netWorthAssets,
                Colors.green,
                () => _addEntry(true),
                (index) {
                  final list = List<FinancialToolEntry>.from(state.netWorthAssets)..removeAt(index);
                  context.read<FinancialBloc>().add(UpdateNetWorthAssetsEvent(list));
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
                  final list = List<FinancialToolEntry>.from(state.netWorthLiabilities)..removeAt(index);
                  context.read<FinancialBloc>().add(UpdateNetWorthLiabilitiesEvent(list));
                },
                currencyCode,
              ),
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
            ),
            IconButton(onPressed: onAdd, icon: const Icon(Icons.add_circle_outline), color: color),
          ],
        ),
        const Divider(),
        if (entries.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('No items added yet.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
          ),
        ...entries.asMap().entries.map((entry) {
          return ListTile(
            title: Text(entry.value.label),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  CurrencyFormatter.format(entry.value.value, currencyCode: currencyCode),
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
