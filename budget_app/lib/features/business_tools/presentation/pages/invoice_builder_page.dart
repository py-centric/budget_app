import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../../domain/entities/company_profile.dart';
import '../../domain/entities/client.dart';
import '../bloc/business_bloc.dart';
import '../bloc/business_event.dart';
import '../bloc/business_state.dart';
import 'pdf_preview_page.dart';

import '../widgets/client_selector_dialog.dart';

class InvoiceBuilderPage extends StatefulWidget {
  final Invoice? initialInvoice;
  const InvoiceBuilderPage({super.key, this.initialInvoice});

  @override
  State<InvoiceBuilderPage> createState() => _InvoiceBuilderPageState();
}

class _InvoiceBuilderPageState extends State<InvoiceBuilderPage> {
  final _invoiceNumberController = TextEditingController(text: 'INV-${DateFormat('yyyyMMdd-HHmm').format(DateTime.now())}');
  final _clientNameController = TextEditingController();
  final _clientDetailsController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Banking overrides
  final _bankNameController = TextEditingController();
  final _bankIbanController = TextEditingController();
  final _bankBicController = TextEditingController();
  final _bankHolderController = TextEditingController();
  
  CompanyProfile? _selectedProfile;
  Client? _selectedClient;
  final List<InvoiceItem> _items = [];
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.initialInvoice != null) {
      _invoiceNumberController.text = widget.initialInvoice!.invoiceNumber;
      _clientNameController.text = widget.initialInvoice!.clientName;
      _clientDetailsController.text = widget.initialInvoice!.clientDetails;
      _notesController.text = widget.initialInvoice!.notes ?? '';
      _date = widget.initialInvoice!.date;

      _bankNameController.text = widget.initialInvoice!.bankName ?? '';
      _bankIbanController.text = widget.initialInvoice!.bankIban ?? '';
      _bankBicController.text = widget.initialInvoice!.bankBic ?? '';
      _bankHolderController.text = widget.initialInvoice!.bankHolder ?? '';
    }

    final state = context.read<BusinessBloc>().state;
    if (state.profiles.isNotEmpty) {
      if (widget.initialInvoice != null) {
        final matches = state.profiles.where((p) => p.id == widget.initialInvoice!.profileId);
        if (matches.isNotEmpty) {
          _selectedProfile = matches.first;
        }
      } else {
        _selectedProfile = state.profiles.first;
        _bankNameController.text = _selectedProfile?.bankName ?? '';
        _bankIbanController.text = _selectedProfile?.bankIban ?? '';
        _bankBicController.text = _selectedProfile?.bankBic ?? '';
        _bankHolderController.text = _selectedProfile?.bankHolder ?? '';
      }
    }
  }

  void _onProfileChanged(CompanyProfile? p) {
    setState(() {
      _selectedProfile = p;
      if (p != null && widget.initialInvoice == null) {
        _bankNameController.text = p.bankName ?? '';
        _bankIbanController.text = p.bankIban ?? '';
        _bankBicController.text = p.bankBic ?? '';
        _bankHolderController.text = p.bankHolder ?? '';
      }
    });
  }

  void _onClientSelected(Client? client) {
    if (client != null) {
      setState(() {
        _selectedClient = client;
        _clientNameController.text = client.name;
        _clientDetailsController.text = '${client.address}\n${client.taxId != null ? 'Tax ID: ${client.taxId}' : ''}'.trim();
      });
    }
  }

  double get _subTotal => _items.fold(0, (sum, item) => sum + (item.quantity * item.rate));
  double get _taxTotal => _items.fold(0, (sum, item) => sum + (item.quantity * item.rate * (item.taxRate / 100)));
  double get _grandTotal => _subTotal + _taxTotal;

  @override
  Widget build(BuildContext context) {
    return BlocListener<BusinessBloc, BusinessState>(
      listenWhen: (previous, current) =>
          (current.lastSavedInvoice != null && previous.lastSavedInvoice == null) ||
          (previous.profiles.isEmpty && current.profiles.isNotEmpty),
      listener: (context, state) {
        if (state.lastSavedInvoice != null && state.lastSavedItems != null) {
          final invoice = state.lastSavedInvoice!;
          final items = state.lastSavedItems!;
          context.read<BusinessBloc>().add(ClearLastSavedInvoice());
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PdfPreviewPage(
                invoice: invoice,
                items: items,
                profile: state.profiles.firstWhere((p) => p.id == invoice.profileId),
              ),
            ),
          );
        }

        if (_selectedProfile == null && state.profiles.isNotEmpty) {
          _onProfileChanged(state.profiles.first);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Invoice'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveInvoice,
            ),
          ],
        ),
        body: BlocBuilder<BusinessBloc, BusinessState>(
          builder: (context, state) {
            if (_selectedClient == null && widget.initialInvoice?.clientId != null) {
              _selectedClient = state.clients.where((c) => c.id == widget.initialInvoice!.clientId).firstOrNull;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(state),
                  const Divider(height: 32),
                  _buildBankingOverrides(),
                  const Divider(height: 32),
                  _buildItemManager(),
                  const Divider(height: 32),
                  _buildSummary(),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'Notes / Footer', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BusinessState state) {
    return Column(
      children: [
        DropdownButtonFormField<CompanyProfile>(
          initialValue: _selectedProfile,
          decoration: const InputDecoration(labelText: 'Sender Profile'),
          items: state.profiles.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
          onChanged: _onProfileChanged,
        ),
        const SizedBox(height: 16),
        TextField(controller: _invoiceNumberController, decoration: const InputDecoration(labelText: 'Invoice Number')),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _clientNameController,
                decoration: const InputDecoration(labelText: 'Client Name'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.contacts),
              tooltip: 'Select from CRM',
              onPressed: () async {
                final client = await ClientSelectorDialog.show(context);
                _onClientSelected(client);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _clientDetailsController,
          decoration: const InputDecoration(labelText: 'Client Details (Address, etc)'),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildBankingOverrides() {
    return ExpansionTile(
      title: const Text('Banking Details (Overrides)'),
      children: [
        TextField(controller: _bankNameController, decoration: const InputDecoration(labelText: 'Bank Name')),
        const SizedBox(height: 8),
        TextField(controller: _bankHolderController, decoration: const InputDecoration(labelText: 'Account Holder')),
        const SizedBox(height: 8),
        TextField(controller: _bankIbanController, decoration: const InputDecoration(labelText: 'IBAN')),
        const SizedBox(height: 8),
        TextField(controller: _bankBicController, decoration: const InputDecoration(labelText: 'BIC/SWIFT')),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildItemManager() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Items', style: Theme.of(context).textTheme.titleLarge),
            TextButton.icon(onPressed: _addItem, icon: const Icon(Icons.add), label: const Text('Add Item')),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return ListTile(
              title: Text(item.description),
              subtitle: Text('${item.quantity} x \$${item.rate.toStringAsFixed(2)} (${item.taxRate}% VAT)'),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => setState(() => _items.removeAt(index)),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummary() {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    return Column(
      children: [
        _summaryRow('Sub-total', currencyFormat.format(_subTotal)),
        _summaryRow('Tax Total', currencyFormat.format(_taxTotal)),
        const Divider(),
        _summaryRow('Grand Total', currencyFormat.format(_grandTotal), isBold: true),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    final style = TextStyle(fontWeight: isBold ? FontWeight.bold : null, fontSize: isBold ? 18 : 14);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: style), Text(value, style: style)]),
    );
  }

  void _addItem() {
    final descController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    final rateController = TextEditingController();
    final taxController = TextEditingController(text: _selectedProfile?.defaultVatRate.toString() ?? '20');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Line Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: qtyController, decoration: const InputDecoration(labelText: 'Quantity'), keyboardType: TextInputType.number),
            TextField(controller: rateController, decoration: const InputDecoration(labelText: 'Rate'), keyboardType: TextInputType.number),
            TextField(controller: taxController, decoration: const InputDecoration(labelText: 'Tax Rate (%)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(qtyController.text) ?? 0.0;
              final rate = double.tryParse(rateController.text) ?? 0.0;
              final tax = double.tryParse(taxController.text) ?? 0.0;
              setState(() {
                _items.add(InvoiceItem(
                  id: const Uuid().v4(),
                  invoiceId: '', // Set when saving
                  description: descController.text,
                  quantity: qty,
                  rate: rate,
                  taxRate: tax,
                  total: qty * rate,
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _saveInvoice() {
    if (_selectedProfile == null || _clientNameController.text.isEmpty || _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields and add at least one item.')));
      return;
    }

    final invoiceId = widget.initialInvoice?.id ?? const Uuid().v4();
    final invoice = Invoice(
      id: invoiceId,
      profileId: _selectedProfile!.id,
      clientId: _selectedClient?.id,
      invoiceNumber: _invoiceNumberController.text,
      date: _date,
      clientName: _clientNameController.text,
      clientDetails: _clientDetailsController.text,
      status: widget.initialInvoice?.status ?? InvoiceStatus.draft,
      subTotal: _subTotal,
      taxTotal: _taxTotal,
      grandTotal: _grandTotal,
      balanceDue: _grandTotal, // Need to handle payments later
      notes: _notesController.text,
      bankName: _bankNameController.text,
      bankIban: _bankIbanController.text,
      bankBic: _bankBicController.text,
      bankHolder: _bankHolderController.text,
    );

    final finalItems = _items.map((it) => it.copyWith(invoiceId: invoiceId)).toList();
    context.read<BusinessBloc>().add(SaveInvoice(invoice, finalItems));
  }
}
