import 'package:flutter/material.dart';
import 'package:budget_app/core/theme/app_spacing.dart';
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
      appBar: AppBar(title: const Text('Financial Tools')),
      body: GridView.count(
        padding: const EdgeInsets.all(AppSpacing.md),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _ToolCard(
            title: 'Net Worth Calculator',
            icon: Icons.account_balance,
            color: Theme.of(context).colorScheme.secondary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NetWorthCalculatorPage()),
            ),
          ),
          _ToolCard(
            title: 'Loan Amortization',
            icon: Icons.real_estate_agent,
            color: Theme.of(context).colorScheme.tertiary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoanCalculatorPage()),
            ),
          ),
          _ToolCard(
            title: 'Savings Goals',
            icon: Icons.savings,
            color: Theme.of(context).colorScheme.primary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SavingsCalculatorPage()),
            ),
          ),
          _ToolCard(
            title: 'Rate Converter',
            icon: Icons.percent,
            color: Theme.of(context).colorScheme.secondary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RateConverterPage()),
            ),
          ),
          _ToolCard(
            title: 'Emergency Fund',
            icon: Icons.health_and_safety,
            color: Theme.of(context).colorScheme.error,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EmergencyCalculatorScreen(),
              ),
            ),
          ),
          _ToolCard(
            title: 'Saved Calculations',
            icon: Icons.bookmark,
            color: Theme.of(context).colorScheme.tertiary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SavedCalculationsPage()),
            ),
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

  const _ToolCard({
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
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            SizedBox(height: AppSpacing.sm + AppSpacing.xs),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
