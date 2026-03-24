import 'package:flutter/foundation.dart';

@immutable
class LoanSummary {
  final double totalOutstanding;
  final int totalLoans;
  final int settledCount;
  final int outstandingCount;
  final int partialCount;

  const LoanSummary({
    required this.totalOutstanding,
    required this.totalLoans,
    required this.settledCount,
    required this.outstandingCount,
    required this.partialCount,
  });

  factory LoanSummary.empty() {
    return const LoanSummary(
      totalOutstanding: 0,
      totalLoans: 0,
      settledCount: 0,
      outstandingCount: 0,
      partialCount: 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoanSummary &&
        other.totalOutstanding == totalOutstanding &&
        other.totalLoans == totalLoans &&
        other.settledCount == settledCount &&
        other.outstandingCount == outstandingCount &&
        other.partialCount == partialCount;
  }

  @override
  int get hashCode {
    return Object.hash(
      totalOutstanding,
      totalLoans,
      settledCount,
      outstandingCount,
      partialCount,
    );
  }
}
