import 'package:equatable/equatable.dart';

enum ReceivedInvoiceStatus { unpaid, partial, paid }

class ReceivedInvoice extends Equatable {
  final String id;
  final String vendorName;
  final String? invoiceNumber;
  final DateTime date;
  final DateTime? dueDate;
  final double amount;
  final double taxAmount;
  final ReceivedInvoiceStatus status;
  final double balanceDue;
  final String? notes;

  const ReceivedInvoice({
    required this.id,
    required this.vendorName,
    this.invoiceNumber,
    required this.date,
    this.dueDate,
    required this.amount,
    required this.taxAmount,
    required this.status,
    required this.balanceDue,
    this.notes,
  });

  ReceivedInvoice copyWith({
    String? id,
    String? vendorName,
    String? invoiceNumber,
    DateTime? date,
    DateTime? dueDate,
    double? amount,
    double? taxAmount,
    ReceivedInvoiceStatus? status,
    double? balanceDue,
    String? notes,
  }) {
    return ReceivedInvoice(
      id: id ?? this.id,
      vendorName: vendorName ?? this.vendorName,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      status: status ?? this.status,
      balanceDue: balanceDue ?? this.balanceDue,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        vendorName,
        invoiceNumber,
        date,
        dueDate,
        amount,
        taxAmount,
        status,
        balanceDue,
        notes,
      ];
}
