import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budget_app/features/accounts/domain/entities/investment_portfolio.dart';

class InvestmentPortfolioCard extends StatelessWidget {
  final InvestmentPortfolio portfolio;
  final VoidCallback onTap;

  const InvestmentPortfolioCard({
    super.key,
    required this.portfolio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final netReturn = portfolio.totalMarketValue - (portfolio.totalDeposited - portfolio.totalWithdrawn);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: colorScheme.tertiaryContainer,
          child: Icon(Icons.show_chart, color: colorScheme.onTertiaryContainer),
        ),
        title: Text(
          portfolio.account.name,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Target Return: ${portfolio.targetAnnualReturnRate.toStringAsFixed(1)}% | Net Return: ${formatter.format(netReturn)}',
        ),
        trailing: Text(
          formatter.format(portfolio.totalMarketValue),
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
