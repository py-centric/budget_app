import '../../domain/entities/income_entry.dart';
import '../../domain/entities/expense_entry.dart';
import 'filter_models.dart';

List<IncomeEntry> filterIncomeEntries(
  List<IncomeEntry> entries,
  FilterState filterState,
) {
  return entries.where((entry) {
    return _matchesFilter(entry, filterState);
  }).toList();
}

List<ExpenseEntry> filterExpenseEntries(
  List<ExpenseEntry> entries,
  FilterState filterState,
) {
  return entries.where((entry) {
    return _matchesFilter(entry, filterState);
  }).toList();
}

bool _matchesFilter(dynamic entry, FilterState filterState) {
  final matchesSearch = _matchesSearch(entry, filterState.searchQuery);
  final matchesAmount = _matchesAmount(entry, filterState.amountFilter);
  final matchesStatus = _matchesStatus(entry, filterState.entryStatus);
  final matchesAccount = _matchesAccount(entry, filterState.accountFilter);

  return matchesSearch && matchesAmount && matchesStatus && matchesAccount;
}

bool _matchesAccount(dynamic entry, AccountFilter accountFilter) {
  if (!accountFilter.isActive) return true;
  String? accountId;
  if (entry is IncomeEntry) {
    accountId = entry.accountId;
  } else if (entry is ExpenseEntry) {
    accountId = entry.accountId;
  }
  return accountFilter.matches(accountId);
}

bool _matchesSearch(dynamic entry, String? searchQuery) {
  if (searchQuery == null || searchQuery.isEmpty) {
    return true;
  }

  final normalizedQuery = searchQuery.toLowerCase().trim();

  if (normalizedQuery.isEmpty) {
    return true;
  }

  final description = _getDescription(entry);

  if (description == null || description.isEmpty) {
    return false;
  }

  final normalizedDescription = description.toLowerCase();

  return _matchesWithSpecialCharacters(normalizedDescription, normalizedQuery);
}

bool _matchesWithSpecialCharacters(String text, String query) {
  final escapedQuery = _escapeRegexCharacters(query);
  final regex = RegExp(escapedQuery, caseSensitive: false);
  return regex.hasMatch(text);
}

String _escapeRegexCharacters(String input) {
  const specialChars = r'[\^$.|?*+(){}';
  final StringBuffer result = StringBuffer();

  for (int i = 0; i < input.length; i++) {
    final char = input[i];
    if (specialChars.contains(char)) {
      result.write('\\');
    }
    result.write(char);
  }

  return result.toString();
}

bool _matchesAmount(dynamic entry, AmountFilter? amountFilter) {
  if (amountFilter == null) {
    return true;
  }

  final amount = _getAmount(entry);
  return amountFilter.matches(amount);
}

String? _getDescription(dynamic entry) {
  if (entry is IncomeEntry) {
    return entry.description;
  } else if (entry is ExpenseEntry) {
    return entry.description;
  }
  return null;
}

double _getAmount(dynamic entry) {
  if (entry is IncomeEntry) {
    return entry.amount;
  } else if (entry is ExpenseEntry) {
    return entry.amount;
  }
  return 0.0;
}

bool _matchesStatus(dynamic entry, EntryStatus status) {
  if (status == EntryStatus.all) return true;

  final isPotential = entry.isPotential;

  switch (status) {
    case EntryStatus.outstanding:
      return isPotential == true;
    case EntryStatus.paid:
      return isPotential != true;
    case EntryStatus.all:
      return true;
  }
}
