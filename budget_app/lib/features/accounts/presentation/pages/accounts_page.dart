import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_event.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_state.dart';
import 'package:budget_app/features/accounts/presentation/widgets/account_form.dart';
import 'package:budget_app/features/accounts/presentation/widgets/transfer_form.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
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
          double totalBalance = 0;

          if (state is AccountLoaded) {
            accounts = state.accounts;
            totalBalance = state.totalBalance;
          } else if (state is TransferSuccess) {
            accounts = state.accounts;
            totalBalance = state.totalBalance;
          } else if (state is TransferError) {
            accounts = state.accounts;
            totalBalance = state.totalBalance;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            });
          }

          if (accounts.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              _buildTotalBalanceCard(context, totalBalance),
              Expanded(child: _buildAccountsList(context, accounts)),
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

  Widget _buildTotalBalanceCard(BuildContext context, double totalBalance) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Balance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(totalBalance),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
          const SizedBox(height: 16),
          Text(
            'No accounts yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
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

  Widget _buildAccountsList(BuildContext context, List<Account> accounts) {
    return ListView.builder(
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return _buildAccountTile(context, account);
      },
    );
  }

  Widget _buildAccountTile(BuildContext context, Account account) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

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
      case AccountType.other:
        accountIcon = Icons.wallet;
        break;
    }

    return Dismissible(
      key: Key(account.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
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
          currencyFormat.format(account.balance),
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
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete "${account.name}"? This will also delete all transfers associated with this account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
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
