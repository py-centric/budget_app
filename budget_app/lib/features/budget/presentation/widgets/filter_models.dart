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

  const FilterState({
    this.searchQuery,
    this.amountFilter,
    this.scope = FilterScope.both,
  });

  bool get hasActiveFilters =>
      (searchQuery != null && searchQuery!.isNotEmpty) || amountFilter != null;

  FilterState copyWith({
    String? searchQuery,
    AmountFilter? amountFilter,
    FilterScope? scope,
    bool clearSearchQuery = false,
    bool clearAmountFilter = false,
  }) {
    return FilterState(
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      amountFilter: clearAmountFilter
          ? null
          : (amountFilter ?? this.amountFilter),
      scope: scope ?? this.scope,
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
        other.scope == scope;
  }

  @override
  int get hashCode =>
      searchQuery.hashCode ^ amountFilter.hashCode ^ scope.hashCode;
}
