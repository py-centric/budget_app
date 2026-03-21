import 'package:budget_app/features/business_tools/domain/entities/received_invoice.dart';

class ReceivedInvoiceModel extends ReceivedInvoice {
  const ReceivedInvoiceModel({
    required super.id,
    required super.vendorName,
    super.invoiceNumber,
    required super.date,
    super.dueDate,
    required super.amount,
    required super.taxAmount,
    required super.status,
    required super.balanceDue,
    super.notes,
  });

  factory ReceivedInvoiceModel.fromMap(Map<String, dynamic> map) {
    return ReceivedInvoiceModel(
      id: map['id'] as String,
      vendorName: map['vendor_name'] as String,
      invoiceNumber: map['invoice_number'] as String?,
      date: DateTime.parse(map['date'] as String),
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date'] as String) : null,
      amount: (map['amount'] as num).toDouble(),
      taxAmount: (map['tax_amount'] as num).toDouble(),
      status: ReceivedInvoiceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      balanceDue: (map['balance_due'] as num).toDouble(),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendor_name': vendorName,
      'invoice_number': invoiceNumber,
      'date': date.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'amount': amount,
      'tax_amount': taxAmount,
      'status': status.toString().split('.').last,
      'balance_due': balanceDue,
      'notes': notes,
    };
  }

  factory ReceivedInvoiceModel.fromEntity(ReceivedInvoice entity) {
    return ReceivedInvoiceModel(
      id: entity.id,
      vendorName: entity.vendorName,
      invoiceNumber: entity.invoiceNumber,
      date: entity.date,
      dueDate: entity.dueDate,
      amount: entity.amount,
      taxAmount: entity.taxAmount,
      status: entity.status,
      balanceDue: entity.balanceDue,
      notes: entity.notes,
    );
  }
}
