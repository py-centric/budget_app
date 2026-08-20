import 'package:flutter/material.dart';
import '../../domain/entities/bill_split.dart';

class BillSplitPage extends StatefulWidget {
  const BillSplitPage({super.key});

  @override
  State<BillSplitPage> createState() => _BillSplitPageState();
}

class _BillSplitPageState extends State<BillSplitPage> {
  final _totalController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameController = TextEditingController();
  final _customAmountController = TextEditingController();
  List<PersonSplit> _splits = [];
  bool _splitEqually = true;

  @override
  void dispose() {
    _totalController.dispose();
    _descriptionController.dispose();
    _nameController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  double get _totalAmount => double.tryParse(_totalController.text) ?? 0;

  void _recalculateSplits() {
    if (_splitEqually && _splits.isNotEmpty && _totalAmount > 0) {
      final perPerson = _totalAmount / _splits.length;
      _splits = _splits.map((s) => s.copyWith(amount: perPerson)).toList();
    }
  }

  void _addPerson() {
    if (_nameController.text.trim().isEmpty) return;
    final name = _nameController.text.trim();
    if (_splits.any((s) => s.name == name)) return;

    setState(() {
      _splits.add(PersonSplit(name: name, amount: 0));
      _recalculateSplits();
    });
    _nameController.clear();
  }

  void _removePerson(int index) {
    setState(() {
      _splits.removeAt(index);
      _recalculateSplits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Bill'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description', hintText: 'e.g. Dinner at restaurant'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _totalController,
              decoration: const InputDecoration(labelText: 'Total Amount', prefixText: '\$'),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(_recalculateSplits),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Person Name'),
                    onSubmitted: (_) => _addPerson(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: _addPerson,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Split Equally'),
              value: _splitEqually,
              onChanged: (val) {
                setState(() {
                  _splitEqually = val;
                  _recalculateSplits();
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _splits.isEmpty
                  ? const Center(
                      child: Text('Add people to split the bill', style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      itemCount: _splits.length,
                      itemBuilder: (context, index) {
                        final split = _splits[index];
                        return ListTile(
                          title: Text(split.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!_splitEqually)
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    controller: TextEditingController(
                                      text: split.amount.toStringAsFixed(2),
                                    ),
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(prefixText: '\$'),
                                    onChanged: (val) {
                                      final amount = double.tryParse(val) ?? 0;
                                      setState(() {
                                        _splits[index] = split.copyWith(amount: amount);
                                      });
                                    },
                                  ),
                                ),
                              if (_splitEqually)
                                Text('\$${split.amount.toStringAsFixed(2)}'),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _removePerson(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (_splits.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:'),
                        Text('\$${_totalAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Split Total:'),
                        Text('\$${_totalAmount > 0 ? (_splits.fold(0.0, (sum, s) => sum + s.amount)).toStringAsFixed(2) : '0.00'}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Remaining:'),
                        Text(
                          '\$${_totalAmount > 0 ? (_totalAmount - _splits.fold(0.0, (sum, s) => sum + s.amount)).toStringAsFixed(2) : '0.00'}',
                          style: TextStyle(
                            color: (_totalAmount - _splits.fold(0.0, (sum, s) => sum + s.amount)).abs() > 0.01
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
