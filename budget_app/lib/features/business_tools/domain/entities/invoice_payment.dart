import 'package:equatable/equatable.dart';

class InvoicePayment extends Equatable {
  final String id;
  final String invoiceId;
  final double amount;
  final DateTime date;
  final String method;

  const InvoicePayment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.date,
    required this.method,
  });

  @override
  List<Object?> get props => [id, invoiceId, amount, date, method];
}
