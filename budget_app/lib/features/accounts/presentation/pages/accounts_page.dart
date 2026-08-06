import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_app/core/theme/app_spacing.dart';
import 'package:budget_app/core/utils/currency_formatter.dart';
import 'package:budget_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:budget_app/shared/widgets/confirm_action_dialog.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/accounts/domain/entities/loan_account.dart';
import 'package:budget_app/features/accounts/domain/entities/savings_account.dart';
import 'package:budget_app/features/accounts/domain/entities/investment_portfolio.dart';
import 'package:budget_app/features/accounts/domain/usecases/calculate_net_worth.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_event.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_state.dart';
import 'package:budget_app/features/accounts/presentation/widgets/account_form.dart';
import 'package:budget_app/features/accounts/presentation/widgets/transfer_form.dart';
import 'package:budget_app/features/accounts/presentation/widgets/net_worth_header.dart';
import 'package:budget_app/features/accounts/presentation/widgets/loan_account_card.dart';
import 'package:budget_app/features/accounts/presentation/widgets/savings_account_card.dart';
import 'package:budget_app/features/accounts/presentation/widgets/investment_portfolio_card.dart';
import 'package:budget_app/features/accounts/presentation/pages/loan_detail_page.dart';
import 'package:budget_app/features/accounts/presentation/pages/savings_detail_page.dart';
import 'package:budget_app/shared/widgets/branding_footer.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts & Portfolios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Transfer',
            onPressed: () => _showTransferDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AccountError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          List<Account> accounts = [];
          List<LoanAccount> loanAccounts = [];
          List<SavingsAccount> savingsAccounts = [];
          List<InvestmentPortfolio> investmentPortfolios = [];
          NetWorthSummary netWorthSummary = const NetWorthSummary(
            totalAssets: 0.0,
            totalLiabilities: 0.0,
            netWorth: 0.0,
          );

          if (state is AccountLoaded) {
            accounts = state.accounts;
            loanAccounts = state.loanAccounts;
            savingsAccounts = state.savingsAccounts;
            investmentPortfolios = state.investmentPortfolios;
            netWorthSummary = state.netWorthSummary;
          } else if (state is TransferSuccess) {
            accounts = state.accounts;
          }

          if (accounts.isEmpty && loanAccounts.isEmpty && savingsAccounts.isEmpty && investmentPortfolios.isEmpty) {
            return Column(
              children: [
                Expanded(child: _buildEmptyState(context)),
                const BrandingFooter(),
              ],
            );
          }

          return ListView(
            children: [
              NetWorthHeader(summary: netWorthSummary),
              if (loanAccounts.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Loan Accounts', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                ...loanAccounts.map((loan) => LoanAccountCard(
                      loanAccount: loan,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LoanDetailPage(loanAccount: loan)),
                        );
                      },
                    )),
              ],
              if (savingsAccounts.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Savings Accounts', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                ...savingsAccounts.map((savings) => SavingsAccountCard(
                      savingsAccount: savings,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SavingsDetailPage(savingsAccount: savings)),
                        );
                      },
                    )),
              ],
              if (investmentPortfolios.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Investment Portfolios', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                ...investmentPortfolios.map((portfolio) => InvestmentPortfolioCard(
                      portfolio: portfolio,
                      onTap: () {},
                    )),
              ],
              if (accounts.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Bank & Operating Accounts', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                ...accounts.map((account) => _buildAccountTile(context, account)),
              ],
              const BrandingFooter(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No accounts yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tap + to add your first account',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTile(BuildContext context, Account account) {
    final currencyCode = context
        .read<SettingsBloc>()
        .state
        .settings
        .currencyCode;

    IconData accountIcon;
    switch (account.type) {
      case AccountType.checking:
        accountIcon = Icons.account_balance;
        break;
      case AccountType.savings:
        accountIcon = Icons.savings;
        break;
      case AccountType.investment:
        accountIcon = Icons.trending_up;
        break;
      case AccountType.loan:
        accountIcon = Icons.money_off;
        break;
      case AccountType.other:
        accountIcon = Icons.wallet;
        break;
    }

    final theme = Theme.of(context);

    return Dismissible(
      key: Key(account.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: theme.colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      confirmDismiss: (direction) => _confirmDelete(context, account),
      onDismissed: (direction) {
        context.read<AccountBloc>().add(DeleteAccount(account.id));
      },
      child: ListTile(
        title: Text(account.name),
        subtitle: Text(account.type.displayName),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            accountIcon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        trailing: Text(
          CurrencyFormatter.format(account.balance, currencyCode: currencyCode),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        onTap: () => _showEditAccountDialog(context, account),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, Account account) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmActionDialog(
        title: 'Delete Account',
        message: 'Are you sure you want to delete "${account.name}"? This will also delete all transfers associated with this account.',
        confirmLabel: 'Delete',
        isDestructive: true,
        onConfirm: () => Navigator.pop(ctx, true),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AccountForm(),
    );
  }

  void _showEditAccountDialog(BuildContext context, Account account) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AccountForm(account: account),
    );
  }

  void _showTransferDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const TransferForm(),
    );
  }
}
