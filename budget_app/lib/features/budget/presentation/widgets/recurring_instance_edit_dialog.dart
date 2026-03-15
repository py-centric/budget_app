import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/recurrence_calculator.dart';
import '../../domain/entities/recurring_override.dart';

class RecurringInstanceEditDialog extends StatefulWidget {
  final RecurringInstance instance;
  final DateTime originalDate;
  final Function(RecurringOverride override) onSave;

  const RecurringInstanceEditDialog({
    super.key,
    required this.instance,
    required this.originalDate,
    required this.onSave,
  });

  @override
  State<RecurringInstanceEditDialog> createState() => _RecurringInstanceEditDialogState();
}

class _RecurringInstanceEditDialogState extends State<RecurringInstanceEditDialog> {
  late TextEditingController _amountController;
  late DateTime _newDate;
  bool _isDeleted = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.instance.amount.toStringAsFixed(2));
    _newDate = widget.instance.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Recurring: ${widget.instance.description}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Cancel this occurrence'),
              value: _isDeleted,
              onChanged: (val) => setState(() => _isDeleted = val ?? false),
            ),
            if (!_isDeleted) ...[
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              ListTile(
                title: Text('Date: ${_newDate.toLocal().toString().split(' ')[0]}'),
                leading: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _newDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _newDate = picked);
                  }
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final override = RecurringOverride(
              id: const Uuid().v4(),
              recurringTransactionId: widget.instance.templateId,
              targetDate: widget.originalDate,
              newAmount: _isDeleted ? null : double.tryParse(_amountController.text),
              newDate: _isDeleted ? null : _newDate,
              isDeleted: _isDeleted,
            );
            widget.onSave(override);
            Navigator.pop(context);
          },
          child: const Text('Save Override'),
        ),
      ],
    );
  }
}
