import 'package:flutter/material.dart';
import 'vat_calculator_page.dart';
import 'invoice_builder_page.dart';
import 'invoices_page.dart';
import 'profile_settings_page.dart';

class BusinessToolsPage extends StatelessWidget {
  const BusinessToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Tools'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _BusinessToolCard(
            title: 'VAT Calculator',
            icon: Icons.calculate,
            color: Colors.blue,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VatCalculatorPage())),
          ),
          _BusinessToolCard(
            title: 'New Invoice',
            icon: Icons.add_chart,
            color: Colors.green,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InvoiceBuilderPage())),
          ),
          _BusinessToolCard(
            title: 'Invoices',
            icon: Icons.history,
            color: Colors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InvoicesPage())),
          ),
          _BusinessToolCard(
            title: 'Business Profiles',
            icon: Icons.business,
            color: Colors.purple,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSettingsPage())),
          ),
        ],
      ),
    );
  }
}

class _BusinessToolCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BusinessToolCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
