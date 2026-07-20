import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Budget App',
      'home': 'Home',
      'transactions': 'Transactions',
      'budgets': 'Budgets',
      'reports': 'Reports',
      'settings': 'Settings',
      'add': 'Add',
      'edit': 'Edit',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'save': 'Save',
      'confirm': 'Confirm',
      'amount': 'Amount',
      'description': 'Description',
      'date': 'Date',
      'category': 'Category',
      'account': 'Account',
      'total': 'Total',
      'balance': 'Balance',
      'income': 'Income',
      'expense': 'Expense',
      'transfer': 'Transfer',
      'no_data': 'No data available',
      'loading': 'Loading...',
      'error': 'An error occurred',
      'retry': 'Retry',
      'search': 'Search',
      'filter': 'Filter',
      'sort': 'Sort',
      'all': 'All',
      'none': 'None',
      'credit_cards': 'Credit Cards',
      'investments': 'Investments',
      'savings': 'Savings',
      'debts': 'Debts',
      'net_worth': 'Net Worth',
      'recent_transactions': 'Recent Transactions',
      'budget_overview': 'Budget Overview',
      'upcoming_bills': 'Upcoming Bills',
      'spending_chart': 'Spending Chart',
      'savings_goals': 'Savings Goals',
      'dashboard_settings': 'Dashboard Settings',
      'split_bill': 'Split Bill',
      'tax_estimation': 'Tax Estimation',
      'achievements': 'Achievements',
      'streak': 'Streak',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
