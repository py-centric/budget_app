import 'package:flutter/material.dart';
import 'package:budget_app/features/emergency_fund/domain/entities/emergency_expense.dart';

class ExpenseItemTile extends StatefulWidget {
  final EmergencyExpense expense;
  final Function(double) onAmountChanged;
  final VoidCallback? onDelete;

  const ExpenseItemTile({
    super.key,
    required this.expense,
    required this.onAmountChanged,
    this.onDelete,
  });

  @override
  State<ExpenseItemTile> createState() => _ExpenseItemTileState();
}

class _ExpenseItemTileState extends State<ExpenseItemTile> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.expense.amount > 0 ? widget.expense.amount.toStringAsFixed(2) : '',
    );
  }

  @override
  void didUpdateWidget(ExpenseItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expense.amount != widget.expense.amount) {
      final text = widget.expense.amount > 0 ? widget.expense.amount.toStringAsFixed(2) : '';
      if (_controller.text != text) {
        _controller.text = text;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.expense.name),
      subtitle: widget.expense.isSuggestion ? const Text('Suggested', style: TextStyle(fontSize: 12)) : null,
      trailing: SizedBox(
        width: 120,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: '\$',
                  hintText: '0.00',
                  labelText: widget.expense.name,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
                onChanged: (value) {
                  final amount = double.tryParse(value) ?? 0.0;
                  if (amount >= 0) {
                    widget.onAmountChanged(amount);
                  }
                },
              ),
            ),
            if (!widget.expense.isSuggestion && widget.onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: widget.onDelete,
                tooltip: 'Delete ${widget.expense.name}',
              ),
          ],
        ),
      ),
    );
  }
}
