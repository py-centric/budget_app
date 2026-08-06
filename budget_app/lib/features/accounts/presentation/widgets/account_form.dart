import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:budget_app/core/utils/currency_formatter.dart';
import 'package:budget_app/features/accounts/domain/entities/account.dart';
import 'package:budget_app/features/accounts/domain/entities/loan_account.dart';
import 'package:budget_app/features/accounts/domain/entities/savings_account.dart';
import 'package:budget_app/features/accounts/domain/entities/investment_portfolio.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:budget_app/features/accounts/presentation/bloc/account_event.dart';
import 'package:budget_app/shared/widgets/currency_selector.dart';

class AccountForm extends StatefulWidget {
  final Account? account;

  const AccountForm({super.key, this.account});

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late TextEditingController _rateController;
  late TextEditingController _minPaymentController;
  late AccountType _selectedType;
  late String _currency;

  bool get isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _balanceController = TextEditingController(
      text: widget.account?.balance.toString() ?? '0.0',
    );
    _rateController = TextEditingController(text: '5.0');
    _minPaymentController = TextEditingController(text: '100.0');
    _selectedType = widget.account?.type ?? AccountType.checking;
    _currency = widget.account?.currency ?? 'USD';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _rateController.dispose();
    _minPaymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Edit Account' : 'Add Account',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Account Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an account name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Account Type',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButton<AccountType>(
                  value: _selectedType,
                  isDense: true,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: AccountType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedType = value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _balanceController,
                decoration: InputDecoration(
                  labelText: _selectedType == AccountType.loan ? 'Principal Amount (\$)' : 'Initial Balance',
                  border: const OutlineInputBorder(),
                  prefixText: '${CurrencyFormatter.getSymbol(currencyCode: _currency)} ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              if (_selectedType == AccountType.loan || _selectedType == AccountType.savings || _selectedType == AccountType.investment) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _rateController,
                  decoration: InputDecoration(
                    labelText: _selectedType == AccountType.loan ? 'Interest Rate (APR %)' : _selectedType == AccountType.savings ? 'Interest Rate (APY %)' : 'Target Annual Return (%)',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
              if (_selectedType == AccountType.loan) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _minPaymentController,
                  decoration: const InputDecoration(
                    labelText: 'Minimum Monthly Repayment (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final currency = await showCurrencySelector(
                    context,
                    initialValue: _currency,
                  );
                  if (currency != null) {
                    setState(() => _currency = currency.code);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Currency',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_currency),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saveAccount,
                child: Text(isEditing ? 'Update' : 'Add Account'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAccount() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final balance = double.parse(_balanceController.text);
      final rate = double.tryParse(_rateController.text) ?? 5.0;
      final minPayment = double.tryParse(_minPaymentController.text) ?? 100.0;

      final account = Account(
        id: widget.account?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        type: _selectedType,
        balance: _selectedType == AccountType.loan ? -balance : balance,
        currency: _currency,
        createdAt: widget.account?.createdAt ?? now,
        updatedAt: now,
      );

      if (_selectedType == AccountType.loan) {
        final loan = LoanAccount(
          account: account,
          originalPrincipal: balance,
          currentPrincipal: balance,
          interestRateApr: rate,
          minimumMonthlyPayment: minPayment,
          originationDate: now,
        );
        context.read<AccountBloc>().add(CreateLoanAccountEvent(loan));
      } else if (_selectedType == AccountType.savings) {
        final savings = SavingsAccount(
          account: account,
          interestRateApy: rate,
          totalContributions: balance,
        );
        context.read<AccountBloc>().add(CreateSavingsAccountEvent(savings));
      } else if (_selectedType == AccountType.investment) {
        final portfolio = InvestmentPortfolio(
          account: account,
          totalMarketValue: balance,
          totalDeposited: balance,
          targetAnnualReturnRate: rate,
        );
        context.read<AccountBloc>().add(CreateInvestmentPortfolioEvent(portfolio));
      } else {
        if (isEditing) {
          context.read<AccountBloc>().add(UpdateAccount(account));
        } else {
          context.read<AccountBloc>().add(AddAccount(account));
        }
      }

      Navigator.pop(context);
    }
  }
}
