import 'package:equatable/equatable.dart';

enum ReconciliationStatus { pending, reconciled, discrepancy }

class ReconciliationEntry extends Equatable {
  final String id;
  final String transactionId;
  final String transactionType;
  final double appAmount;
  final double? bankAmount;
  final DateTime date;
  final ReconciliationStatus status;
  final String? note;

  const ReconciliationEntry({
    required this.id,
    required this.transactionId,
    required this.transactionType,
    required this.appAmount,
    this.bankAmount,
    required this.date,
    this.status = ReconciliationStatus.pending,
    this.note,
  });

  @override
  List<Object?> get props => [id, transactionId, transactionType, appAmount, bankAmount, date, status, note];
}
