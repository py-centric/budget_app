import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/client.dart';
import '../bloc/business_bloc.dart';
import '../bloc/business_event.dart';

class ClientEditPage extends StatefulWidget {
  final Client? client;

  const ClientEditPage({super.key, this.client});

  @override
  State<ClientEditPage> createState() => _ClientEditPageState();
}

class _ClientEditPageState extends State<ClientEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _taxIdController;
  late TextEditingController _primaryContactController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _industryController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client?.name);
    _addressController = TextEditingController(text: widget.client?.address);
    _taxIdController = TextEditingController(text: widget.client?.taxId);
    _primaryContactController = TextEditingController(text: widget.client?.primaryContact);
    _emailController = TextEditingController(text: widget.client?.email);
    _phoneController = TextEditingController(text: widget.client?.phone);
    _websiteController = TextEditingController(text: widget.client?.website);
    _industryController = TextEditingController(text: widget.client?.industry);
    _notesController = TextEditingController(text: widget.client?.notes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _taxIdController.dispose();
    _primaryContactController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _industryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client == null ? 'Add Client' : 'Edit Client'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveClient,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Company/Client Name *')),
            const SizedBox(height: 16),
            TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Billing Address *'), maxLines: 3),
            const SizedBox(height: 16),
            TextField(controller: _taxIdController, decoration: const InputDecoration(labelText: 'Tax/VAT ID')),
            const SizedBox(height: 16),
            const Divider(),
            const Text('Contact Information', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _primaryContactController, decoration: const InputDecoration(labelText: 'Primary Contact Person')),
            const SizedBox(height: 16),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email Address')),
            const SizedBox(height: 16),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
            const SizedBox(height: 16),
            const Divider(),
            const Text('Additional Details', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _websiteController, decoration: const InputDecoration(labelText: 'Website')),
            const SizedBox(height: 16),
            TextField(controller: _industryController, decoration: const InputDecoration(labelText: 'Industry')),
            const SizedBox(height: 16),
            TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Internal Notes'), maxLines: 3),
          ],
        ),
      ),
    );
  }

  void _saveClient() {
    if (_nameController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and Address are required.')));
      return;
    }

    final newClient = Client(
      id: widget.client?.id ?? const Uuid().v4(),
      name: _nameController.text,
      address: _addressController.text,
      taxId: _taxIdController.text,
      primaryContact: _primaryContactController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      website: _websiteController.text,
      industry: _industryController.text,
      notes: _notesController.text,
    );

    context.read<BusinessBloc>().add(SaveClient(newClient));
    Navigator.pop(context);
  }
}
