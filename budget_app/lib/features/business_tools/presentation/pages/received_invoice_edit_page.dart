import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/received_invoice.dart';
import '../bloc/business_bloc.dart';
import '../bloc/business_event.dart';

class ReceivedInvoiceEditPage extends StatefulWidget {
  final ReceivedInvoice? invoice;

  const ReceivedInvoiceEditPage({super.key, this.invoice});

  @override
  State<ReceivedInvoiceEditPage> createState() =>
      _ReceivedInvoiceEditPageState();
}

class _ReceivedInvoiceEditPageState extends State<ReceivedInvoiceEditPage> {
  late TextEditingController _vendorController;
  late TextEditingController _invoiceNumController;
  late TextEditingController _amountController;
  late TextEditingController _taxController;
  late TextEditingController _notesController;
  late DateTime _date;
  DateTime? _dueDate;
  late ReceivedInvoiceStatus _status;

  @override
  void initState() {
    super.initState();
    _vendorController = TextEditingController(text: widget.invoice?.vendorName);
    _invoiceNumController = TextEditingController(
      text: widget.invoice?.invoiceNumber,
    );
    _amountController = TextEditingController(
      text: widget.invoice?.amount.toString(),
    );
    _taxController = TextEditingController(
      text: widget.invoice?.taxAmount.toString(),
    );
    _notesController = TextEditingController(text: widget.invoice?.notes);
    _date = widget.invoice?.date ?? DateTime.now();
    _dueDate = widget.invoice?.dueDate;
    _status = widget.invoice?.status ?? ReceivedInvoiceStatus.unpaid;
  }

  @override
  void dispose() {
    _vendorController.dispose();
    _invoiceNumController.dispose();
    _amountController.dispose();
    _taxController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.invoice == null
              ? 'Add Received Invoice'
              : 'Edit Received Invoice',
        ),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _vendorController,
              decoration: const InputDecoration(labelText: 'Vendor Name *'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _invoiceNumController,
              decoration: const InputDecoration(labelText: 'Invoice Number'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Total Amount *',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _taxController,
                    decoration: const InputDecoration(labelText: 'Tax Amount'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            ListTile(
              title: const Text('Due Date'),
              subtitle: Text(
                _dueDate != null
                    ? DateFormat('yyyy-MM-dd').format(_dueDate!)
                    : 'Not set',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _dueDate = picked);
              },
            ),
            DropdownButtonFormField<ReceivedInvoiceStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: ReceivedInvoiceStatus.values.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(s.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) => setState(() => _status = val!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_vendorController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final tax = double.tryParse(_taxController.text) ?? 0.0;

    final invoice = ReceivedInvoice(
      id: widget.invoice?.id ?? const Uuid().v4(),
      vendorName: _vendorController.text,
      invoiceNumber: _invoiceNumController.text,
      date: _date,
      dueDate: _dueDate,
      amount: amount,
      taxAmount: tax,
      status: _status,
      balanceDue: _status == ReceivedInvoiceStatus.paid
          ? 0
          : amount, // Simple logic
      notes: _notesController.text,
    );

    context.read<BusinessBloc>().add(SaveReceivedInvoice(invoice));
    Navigator.pop(context);
  }
}
