import 'package:flutter/foundation.dart';

enum LoanStatus {
  outstanding,
  partial,
  settled;

  String get displayName {
    switch (this) {
      case LoanStatus.outstanding:
        return 'Outstanding';
      case LoanStatus.partial:
        return 'Partial';
      case LoanStatus.settled:
        return 'Settled';
    }
  }

  static LoanStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'outstanding':
        return LoanStatus.outstanding;
      case 'partial':
        return LoanStatus.partial;
      case 'settled':
        return LoanStatus.settled;
      default:
        return LoanStatus.outstanding;
    }
  }
}

enum LoanDirection {
  lent,
  owed;

  String get displayName {
    switch (this) {
      case LoanDirection.lent:
        return 'Lent by Me';
      case LoanDirection.owed:
        return 'Owed to Me';
    }
  }

  static LoanDirection fromString(String value) {
    switch (value.toLowerCase()) {
      case 'lent':
        return LoanDirection.lent;
      case 'owed':
        return LoanDirection.owed;
      default:
        return LoanDirection.lent;
    }
  }
}

@immutable
class Loan {
  final String id;
  final String borrowerName;
  final double loanAmount;
  final DateTime loanDate;
  final LoanStatus status;
  final double remainingBalance;
  final String? notes;
  final LoanDirection direction;
  final bool includeInProjections;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Loan({
    required this.id,
    required this.borrowerName,
    required this.loanAmount,
    required this.loanDate,
    required this.status,
    required this.remainingBalance,
    this.notes,
    this.direction = LoanDirection.lent,
    this.includeInProjections = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Loan copyWith({
    String? id,
    String? borrowerName,
    double? loanAmount,
    DateTime? loanDate,
    LoanStatus? status,
    double? remainingBalance,
    String? notes,
    LoanDirection? direction,
    bool? includeInProjections,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Loan(
      id: id ?? this.id,
      borrowerName: borrowerName ?? this.borrowerName,
      loanAmount: loanAmount ?? this.loanAmount,
      loanDate: loanDate ?? this.loanDate,
      status: status ?? this.status,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      notes: notes ?? this.notes,
      direction: direction ?? this.direction,
      includeInProjections: includeInProjections ?? this.includeInProjections,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Loan &&
        other.id == id &&
        other.borrowerName == borrowerName &&
        other.loanAmount == loanAmount &&
        other.loanDate == loanDate &&
        other.status == status &&
        other.remainingBalance == remainingBalance &&
        other.notes == notes &&
        other.direction == direction &&
        other.includeInProjections == includeInProjections &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      borrowerName,
      loanAmount,
      loanDate,
      status,
      remainingBalance,
      notes,
      direction,
      includeInProjections,
      createdAt,
      updatedAt,
    );
  }
}
