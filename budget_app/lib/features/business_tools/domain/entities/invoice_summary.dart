import 'package:equatable/equatable.dart';

class InvoiceSummary extends Equatable {
  final double totalReceivables;
  final double totalPayables;
  final int paidCount;
  final int unpaidCount;
  final int partialCount;

  const InvoiceSummary({
    required this.totalReceivables,
    required this.totalPayables,
    required this.paidCount,
    required this.unpaidCount,
    required this.partialCount,
  });

  @override
  List<Object?> get props => [
        totalReceivables,
        totalPayables,
        paidCount,
        unpaidCount,
        partialCount,
      ];
}
