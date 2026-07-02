import 'package:flutter/material.dart';

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

class FilterState {
  final String? searchQuery;
  final AmountFilter? amountFilter;
  final FilterScope scope;
  final EntryStatus entryStatus;

  const FilterState({
    this.searchQuery,
    this.amountFilter,
    this.scope = FilterScope.both,
    this.entryStatus = EntryStatus.all,
  });

  bool get hasActiveFilters =>
      (searchQuery != null && searchQuery!.isNotEmpty) ||
      amountFilter != null ||
      entryStatus != EntryStatus.all;

  FilterState copyWith({
    String? searchQuery,
    AmountFilter? amountFilter,
    FilterScope? scope,
    EntryStatus? entryStatus,
    bool clearSearchQuery = false,
    bool clearAmountFilter = false,
    bool clearEntryStatus = false,
  }) {
    return FilterState(
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      amountFilter: clearAmountFilter
          ? null
          : (amountFilter ?? this.amountFilter),
      scope: scope ?? this.scope,
      entryStatus: clearEntryStatus
          ? EntryStatus.all
          : (entryStatus ?? this.entryStatus),
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
        other.scope == scope &&
        other.entryStatus == entryStatus;
  }

  @override
  int get hashCode =>
      searchQuery.hashCode ^
      amountFilter.hashCode ^
      scope.hashCode ^
      entryStatus.hashCode;
}
