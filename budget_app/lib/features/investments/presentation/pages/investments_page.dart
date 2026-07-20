import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/investment_bloc.dart';
import '../bloc/investment_event.dart';
import '../bloc/investment_state.dart';
import '../../domain/entities/investment.dart';

class InvestmentsPage extends StatelessWidget {
  const InvestmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investments'),
      ),
      body: BlocBuilder<InvestmentBloc, InvestmentState>(
        builder: (context, state) {
          if (state is InvestmentLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is InvestmentLoaded) {
            if (state.investments.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No investments yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    SizedBox(height: 8),
                    Text('Tap + to add your first investment'),
                  ],
                ),
              );
            }
            final totalValue = state.investments.fold(0.0, (sum, i) => sum + i.totalValue);
            final totalCost = state.investments.fold(0.0, (sum, i) => sum + i.totalCost);
            final totalGainLoss = totalValue - totalCost;
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Column(
                    children: [
                      Text(
                        'Total Value: \$${totalValue.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Gain/Loss: \$${totalGainLoss.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: totalGainLoss >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.investments.length,
                    itemBuilder: (context, index) {
                      final investment = state.investments[index];
                      return _InvestmentTile(investment: investment);
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final tickerController = TextEditingController();
    final sharesController = TextEditingController();
    final avgCostController = TextEditingController();
    final priceController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Investment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                autofocus: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: tickerController,
                decoration: const InputDecoration(labelText: 'Ticker'),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: sharesController,
                decoration: const InputDecoration(labelText: 'Shares'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: avgCostController,
                decoration: const InputDecoration(labelText: 'Avg Cost Per Share', prefixText: '\$'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Current Price', prefixText: '\$'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty && tickerController.text.trim().isNotEmpty) {
                context.read<InvestmentBloc>().add(AddInvestmentEvent(
                  name: nameController.text.trim(),
                  ticker: tickerController.text.trim().toUpperCase(),
                  shares: double.tryParse(sharesController.text) ?? 0,
                  avgCost: double.tryParse(avgCostController.text) ?? 0,
                  currentPrice: double.tryParse(priceController.text) ?? 0,
                ));
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _InvestmentTile extends StatelessWidget {
  final Investment investment;

  const _InvestmentTile({required this.investment});

  @override
  Widget build(BuildContext context) {
    final isPositive = investment.gainLoss >= 0;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${investment.ticker}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('\$${investment.totalValue.toStringAsFixed(2)}'),
          ],
        ),
        subtitle: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(investment.name, style: const TextStyle(fontSize: 12)),
                Text(
                  '${isPositive ? '+' : ''}\$${investment.gainLoss.toStringAsFixed(2)} (${investment.roi.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    fontSize: 12,
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${investment.shares.toStringAsFixed(2)} shares @ \$${investment.avgCost.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  'Current: \$${investment.currentPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showEditDialog(context, investment),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () => _confirmDelete(context, investment),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Investment investment) {
    final nameController = TextEditingController(text: investment.name);
    final tickerController = TextEditingController(text: investment.ticker);
    final sharesController = TextEditingController(text: investment.shares.toStringAsFixed(2));
    final avgCostController = TextEditingController(text: investment.avgCost.toStringAsFixed(2));
    final priceController = TextEditingController(text: investment.currentPrice.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Investment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 8),
              TextField(controller: tickerController, decoration: const InputDecoration(labelText: 'Ticker')),
              const SizedBox(height: 8),
              TextField(controller: sharesController, decoration: const InputDecoration(labelText: 'Shares'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(controller: avgCostController, decoration: const InputDecoration(labelText: 'Avg Cost', prefixText: '\$'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Current Price', prefixText: '\$'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              context.read<InvestmentBloc>().add(UpdateInvestmentEvent(
                investment.copyWith(
                  name: nameController.text.trim(),
                  ticker: tickerController.text.trim().toUpperCase(),
                  shares: double.tryParse(sharesController.text) ?? investment.shares,
                  avgCost: double.tryParse(avgCostController.text) ?? investment.avgCost,
                  currentPrice: double.tryParse(priceController.text) ?? investment.currentPrice,
                ),
              ));
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Investment investment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Investment'),
        content: Text('Delete "${investment.name}" (${investment.ticker})?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              context.read<InvestmentBloc>().add(DeleteInvestmentEvent(investment.id));
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
