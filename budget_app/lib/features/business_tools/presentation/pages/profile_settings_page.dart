import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../domain/entities/company_profile.dart';
import '../bloc/business_bloc.dart';
import '../bloc/business_event.dart';
import '../bloc/business_state.dart';
import '../utils/logo_picker.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profiles'),
      ),
      body: BlocBuilder<BusinessBloc, BusinessState>(
        builder: (context, state) {
          if (state.status == BusinessStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.profiles.length,
            itemBuilder: (context, index) {
              final profile = state.profiles[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: profile.logoPath != null ? FileImage(File(profile.logoPath!)) : null,
                    child: profile.logoPath == null ? Text(profile.name[0].toUpperCase()) : null,
                  ),
                  title: Text(profile.name),
                  subtitle: Text(profile.taxId ?? 'No Tax ID'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showProfileDialog(context, profile: profile),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => context.read<BusinessBloc>().add(DeleteProfile(profile.id)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProfileDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, {CompanyProfile? profile}) {
    final nameController = TextEditingController(text: profile?.name);
    final addressController = TextEditingController(text: profile?.address);
    final taxIdController = TextEditingController(text: profile?.taxId);
    final paymentController = TextEditingController(text: profile?.paymentInfo);
    final vatRateController = TextEditingController(text: profile?.defaultVatRate.toString() ?? '20');
    final bankNameController = TextEditingController(text: profile?.bankName);
    final bankIbanController = TextEditingController(text: profile?.bankIban);
    final bankBicController = TextEditingController(text: profile?.bankBic);
    final bankHolderController = TextEditingController(text: profile?.bankHolder);

    String? logoPath = profile?.logoPath;
    int? primaryColor = profile?.primaryColor ?? Colors.blue.value;
    String? fontFamily = profile?.fontFamily ?? 'Helvetica';
    bool logoOnRight = profile?.logoOnRight ?? false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(profile == null ? 'Add Profile' : 'Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final path = await LogoPicker.pickAndSaveLogo();
                      if (path != null) {
                        setState(() => logoPath = path);
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: logoPath != null
                          ? Image.file(File(logoPath!), fit: BoxFit.contain)
                          : const Icon(Icons.add_a_photo, size: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Logo on Right'),
                  value: logoOnRight,
                  onChanged: (val) => setState(() => logoOnRight = val),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Business Name'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  maxLines: 2,
                ),
                TextField(
                  controller: taxIdController,
                  decoration: const InputDecoration(labelText: 'Tax/VAT ID'),
                ),
                TextField(
                  controller: vatRateController,
                  decoration: const InputDecoration(labelText: 'Default VAT Rate (%)', suffixText: '%'),
                  keyboardType: TextInputType.number,
                ),
                const Divider(),
                const Text('Banking Details', style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: bankNameController,
                  decoration: const InputDecoration(labelText: 'Bank Name'),
                ),
                TextField(
                  controller: bankHolderController,
                  decoration: const InputDecoration(labelText: 'Account Holder'),
                ),
                TextField(
                  controller: bankIbanController,
                  decoration: const InputDecoration(labelText: 'IBAN'),
                ),
                TextField(
                  controller: bankBicController,
                  decoration: const InputDecoration(labelText: 'BIC/SWIFT'),
                ),
                const Divider(),
                const Text('Styling', style: TextStyle(fontWeight: FontWeight.bold)),
                ListTile(
                  title: const Text('Brand Color'),
                  trailing: Container(
                    width: 24,
                    height: 24,
                    color: Color(primaryColor!),
                  ),
                  onTap: () {
                    // Simple color picker
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Pick Brand Color'),
                        content: Wrap(
                          spacing: 8,
                          children: [
                            Colors.blue,
                            Colors.red,
                            Colors.green,
                            Colors.orange,
                            Colors.purple,
                            Colors.black,
                          ].map((c) => GestureDetector(
                            onTap: () {
                              setState(() => primaryColor = c.value);
                              Navigator.pop(context);
                            },
                            child: CircleAvatar(backgroundColor: c),
                          )).toList(),
                        ),
                      ),
                    );
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue: fontFamily,
                  decoration: const InputDecoration(labelText: 'Font Family'),
                  items: ['Helvetica', 'Courier', 'Times-Roman']
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (val) => setState(() => fontFamily = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newProfile = CompanyProfile(
                  id: profile?.id ?? const Uuid().v4(),
                  name: nameController.text,
                  address: addressController.text,
                  taxId: taxIdController.text,
                  logoPath: logoPath,
                  paymentInfo: paymentController.text,
                  defaultVatRate: double.tryParse(vatRateController.text) ?? 0.0,
                  bankName: bankNameController.text,
                  bankIban: bankIbanController.text,
                  bankBic: bankBicController.text,
                  bankHolder: bankHolderController.text,
                  primaryColor: primaryColor,
                  fontFamily: fontFamily,
                  logoOnRight: logoOnRight,
                );
                context.read<BusinessBloc>().add(SaveProfile(newProfile));
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
