import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum SortField {
  date,
  amount,
  name;

  String get label {
    switch (this) {
      case SortField.date:
        return 'Date';
      case SortField.amount:
        return 'Amount';
      case SortField.name:
        return 'Name';
    }
  }

  IconData get icon {
    switch (this) {
      case SortField.date:
        return Icons.calendar_today;
      case SortField.amount:
        return Icons.attach_money;
      case SortField.name:
        return Icons.sort_by_alpha;
    }
  }
}

enum SortOrder {
  ascending,
  descending;

  String get label =>
      this == SortOrder.ascending ? 'Ascending' : 'Descending';

  IconData get icon =>
      this == SortOrder.ascending ? Icons.arrow_upward : Icons.arrow_downward;
}

enum GroupMode {
  category,
  none,
  dateWeek,
  dateMonth;

  String get label {
    switch (this) {
      case GroupMode.category:
        return 'Category';
      case GroupMode.none:
        return 'None';
      case GroupMode.dateWeek:
        return 'Week';
      case GroupMode.dateMonth:
        return 'Month';
    }
  }

  IconData get icon {
    switch (this) {
      case GroupMode.category:
        return Icons.category;
      case GroupMode.none:
        return Icons.view_list;
      case GroupMode.dateWeek:
        return Icons.view_week;
      case GroupMode.dateMonth:
        return Icons.calendar_month;
    }
  }
}

enum EntryStatus {
  all,
  outstanding,
  paid;

  String get label {
    switch (this) {
      case EntryStatus.all:
        return 'All';
      case EntryStatus.outstanding:
        return 'Outstanding';
      case EntryStatus.paid:
        return 'Paid';
    }
  }

  IconData get icon {
    switch (this) {
      case EntryStatus.all:
        return Icons.list;
      case EntryStatus.outstanding:
        return Icons.pending_actions;
      case EntryStatus.paid:
        return Icons.check_circle_outline;
    }
  }
}

enum AmountOperator {
  lessThan,
  greaterThan,
  equals;

  String get label {
    switch (this) {
      case AmountOperator.lessThan:
        return 'Less than';
      case AmountOperator.greaterThan:
        return 'Greater than';
      case AmountOperator.equals:
        return 'Equals';
    }
  }

  String get symbol {
    switch (this) {
      case AmountOperator.lessThan:
        return '<';
      case AmountOperator.greaterThan:
        return '>';
      case AmountOperator.equals:
        return '=';
    }
  }
}

enum FilterScope {
  incomeOnly,
  expenseOnly,
  both;

  String get label {
    switch (this) {
      case FilterScope.incomeOnly:
        return 'Income';
      case FilterScope.expenseOnly:
        return 'Expenses';
      case FilterScope.both:
        return 'All';
    }
  }
}

class AmountFilter {
  final AmountOperator operator;
  final double value;

  const AmountFilter({required this.operator, required this.value});

  bool matches(double amount) {
    switch (operator) {
      case AmountOperator.lessThan:
        return amount < value;
      case AmountOperator.greaterThan:
        return amount > value;
      case AmountOperator.equals:
        return amount == value;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AmountFilter &&
        other.operator == operator &&
        other.value == value;
  }

  @override
  int get hashCode => operator.hashCode ^ value.hashCode;
}

class AccountFilter {
  final Set<String> selectedAccountIds;
  final bool includeUnassigned;

  const AccountFilter({
    this.selectedAccountIds = const {},
    this.includeUnassigned = false,
  });

  bool get isActive => selectedAccountIds.isNotEmpty || includeUnassigned;

  bool matches(String? accountId) {
    if (!isActive) return true;
    if (accountId == null) {
      return includeUnassigned;
    }
    return selectedAccountIds.contains(accountId);
  }

  AccountFilter copyWith({
    Set<String>? selectedAccountIds,
    bool? includeUnassigned,
  }) {
    return AccountFilter(
      selectedAccountIds: selectedAccountIds ?? this.selectedAccountIds,
      includeUnassigned: includeUnassigned ?? this.includeUnassigned,
    );
  }

  AccountFilter toggleAccount(String id) {
    final newSet = Set<String>.from(selectedAccountIds);
    if (newSet.contains(id)) {
      newSet.remove(id);
    } else {
      newSet.add(id);
    }
    return copyWith(selectedAccountIds: newSet);
  }

  AccountFilter toggleUnassigned() {
    return copyWith(includeUnassigned: !includeUnassigned);
  }

  AccountFilter clear() {
    return const AccountFilter();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccountFilter &&
        setEquals(other.selectedAccountIds, selectedAccountIds) &&
        other.includeUnassigned == includeUnassigned;
  }

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(selectedAccountIds), includeUnassigned);
}

class FilterState {
  final String? searchQuery;
  final AmountFilter? amountFilter;
  final AccountFilter accountFilter;
  final FilterScope scope;
  final EntryStatus entryStatus;
  final SortField sortField;
  final SortOrder sortOrder;
  final GroupMode groupMode;

  const FilterState({
    this.searchQuery,
    this.amountFilter,
    this.accountFilter = const AccountFilter(),
    this.scope = FilterScope.both,
    this.entryStatus = EntryStatus.all,
    this.sortField = SortField.date,
    this.sortOrder = SortOrder.descending,
    this.groupMode = GroupMode.category,
  });

  bool get hasActiveFilters =>
      (searchQuery != null && searchQuery!.isNotEmpty) ||
      amountFilter != null ||
      entryStatus != EntryStatus.all ||
      accountFilter.isActive;

  bool get hasActiveSortGroup =>
      sortField != SortField.date ||
      sortOrder != SortOrder.descending ||
      groupMode != GroupMode.category;

  bool get hasActiveDisplayOptions => hasActiveSortGroup;

  FilterState copyWith({
    String? searchQuery,
    AmountFilter? amountFilter,
    AccountFilter? accountFilter,
    FilterScope? scope,
    EntryStatus? entryStatus,
    SortField? sortField,
    SortOrder? sortOrder,
    GroupMode? groupMode,
    bool clearSearchQuery = false,
    bool clearAmountFilter = false,
    bool clearAccountFilter = false,
    bool clearEntryStatus = false,
  }) {
    return FilterState(
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      amountFilter: clearAmountFilter
          ? null
          : (amountFilter ?? this.amountFilter),
      accountFilter: clearAccountFilter
          ? const AccountFilter()
          : (accountFilter ?? this.accountFilter),
      scope: scope ?? this.scope,
      entryStatus: clearEntryStatus
          ? EntryStatus.all
          : (entryStatus ?? this.entryStatus),
      sortField: sortField ?? this.sortField,
      sortOrder: sortOrder ?? this.sortOrder,
      groupMode: groupMode ?? this.groupMode,
    );
  }

  FilterState clearAll() {
    return const FilterState();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilterState &&
        other.searchQuery == searchQuery &&
        other.amountFilter == amountFilter &&
        other.accountFilter == accountFilter &&
        other.scope == scope &&
        other.entryStatus == entryStatus &&
        other.sortField == sortField &&
        other.sortOrder == sortOrder &&
        other.groupMode == groupMode;
  }

  @override
  int get hashCode =>
      searchQuery.hashCode ^
      amountFilter.hashCode ^
      accountFilter.hashCode ^
      scope.hashCode ^
      entryStatus.hashCode ^
      sortField.hashCode ^
      sortOrder.hashCode ^
      groupMode.hashCode;
}
