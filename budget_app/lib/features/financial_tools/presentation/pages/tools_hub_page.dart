import 'package:flutter/material.dart';
import 'net_worth_calculator_page.dart';
import 'loan_calculator_page.dart';
import 'savings_calculator_page.dart';
import 'saved_calculations_page.dart';
import 'rate_converter_page.dart';
import '../../../../features/emergency_fund/presentation/pages/emergency_calculator_screen.dart';

class ToolsHubPage extends StatelessWidget {
  const ToolsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Tools'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _ToolCard(
            title: 'Net Worth',
            icon: Icons.account_balance_wallet,
            color: Colors.blue,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NetWorthCalculatorPage())),
          ),
          _ToolCard(
            title: 'Loans',
            icon: Icons.monetization_on,
            color: Colors.red,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoanCalculatorPage())),
          ),
          _ToolCard(
            title: 'Savings',
            icon: Icons.trending_up,
            color: Colors.green,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SavingsCalculatorPage())),
          ),
          _ToolCard(
            title: 'Rate Solver',
            icon: Icons.functions,
            color: Colors.purple,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RateConverterPage())),
          ),
          _ToolCard(
            title: 'Emergency Fund',
            icon: Icons.shield,
            color: Colors.amber,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyCalculatorScreen())),
          ),
          _ToolCard(
            title: 'Saved Items',
            icon: Icons.history,
            color: Colors.orange,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedCalculationsPage())),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ToolCard({required this.title, required this.icon, required this.color, required this.onTap});

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
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
