import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/credit_card_bloc.dart';
import '../bloc/credit_card_event.dart';
import '../bloc/credit_card_state.dart';
import '../../domain/entities/credit_card.dart';

class CreditCardsPage extends StatelessWidget {
  const CreditCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Cards'),
      ),
      body: BlocBuilder<CreditCardBloc, CreditCardState>(
        builder: (context, state) {
          if (state is CreditCardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CreditCardLoaded) {
            if (state.creditCards.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.credit_card_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No credit cards yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    SizedBox(height: 8),
                    Text('Tap + to add your first credit card'),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.creditCards.length,
              itemBuilder: (context, index) {
                final card = state.creditCards[index];
                return _CreditCardTile(card: card);
              },
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
    final lastFourController = TextEditingController();
    final limitController = TextEditingController();
    final balanceController = TextEditingController();
    final aprController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Credit Card'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Card Name'),
                autofocus: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lastFourController,
                decoration: const InputDecoration(labelText: 'Last 4 Digits'),
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: limitController,
                decoration: const InputDecoration(labelText: 'Credit Limit', prefixText: '\$'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: balanceController,
                decoration: const InputDecoration(labelText: 'Current Balance', prefixText: '\$'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: aprController,
                decoration: const InputDecoration(labelText: 'APR %', suffixText: '%'),
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
              if (nameController.text.trim().isNotEmpty && limitController.text.isNotEmpty) {
                context.read<CreditCardBloc>().add(CreateCreditCardEvent(
                  name: nameController.text.trim(),
                  lastFour: lastFourController.text.trim().isNotEmpty ? lastFourController.text.trim() : null,
                  creditLimit: double.tryParse(limitController.text) ?? 0,
                  currentBalance: double.tryParse(balanceController.text) ?? 0,
                  apr: double.tryParse(aprController.text) ?? 0,
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

class _CreditCardTile extends StatelessWidget {
  final CreditCard card;

  const _CreditCardTile({required this.card});

  @override
  Widget build(BuildContext context) {
    final utilization = card.utilizationPercent / 100;
    final utilizationColor = utilization > 0.7
        ? Colors.red
        : utilization > 0.3
            ? Colors.orange
            : Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.credit_card, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      card.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (card.lastFour != null)
                      Text(
                        ' ••••${card.lastFour}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditDialog(context, card),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _confirmDelete(context, card),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Balance: \$${card.currentBalance.toStringAsFixed(2)}'),
                Text('Limit: \$${card.creditLimit.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Available: \$${card.availableCredit.toStringAsFixed(2)}'),
                Text('APR: ${card.apr.toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: utilization.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                color: utilizationColor,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Utilization: ${card.utilizationPercent.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: utilizationColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, CreditCard card) {
    final nameController = TextEditingController(text: card.name);
    final limitController = TextEditingController(text: card.creditLimit.toStringAsFixed(2));
    final balanceController = TextEditingController(text: card.currentBalance.toStringAsFixed(2));
    final aprController = TextEditingController(text: card.apr.toStringAsFixed(1));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Credit Card'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Card Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: limitController,
                decoration: const InputDecoration(labelText: 'Credit Limit', prefixText: '\$'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: balanceController,
                decoration: const InputDecoration(labelText: 'Current Balance', prefixText: '\$'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: aprController,
                decoration: const InputDecoration(labelText: 'APR %', suffixText: '%'),
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
              if (nameController.text.trim().isNotEmpty) {
                context.read<CreditCardBloc>().add(UpdateCreditCardEvent(
                  card.copyWith(
                    name: nameController.text.trim(),
                    creditLimit: double.tryParse(limitController.text) ?? card.creditLimit,
                    currentBalance: double.tryParse(balanceController.text) ?? card.currentBalance,
                    apr: double.tryParse(aprController.text) ?? card.apr,
                  ),
                ));
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, CreditCard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Credit Card'),
        content: Text('Delete "${card.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<CreditCardBloc>().add(DeleteCreditCardEvent(card.id));
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
