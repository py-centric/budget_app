import 'package:budget_app/features/business_tools/domain/entities/invoice_payment.dart';

class InvoicePaymentModel extends InvoicePayment {
  const InvoicePaymentModel({
    required super.id,
    required super.invoiceId,
    required super.amount,
    required super.date,
    required super.method,
  });

  factory InvoicePaymentModel.fromMap(Map<String, dynamic> map) {
    return InvoicePaymentModel(
      id: map['id'] as String,
      invoiceId: map['invoice_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      method: map['method'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'amount': amount,
      'date': date.toIso8601String(),
      'method': method,
    };
  }

  factory InvoicePaymentModel.fromEntity(InvoicePayment entity) {
    return InvoicePaymentModel(
      id: entity.id,
      invoiceId: entity.invoiceId,
      amount: entity.amount,
      date: entity.date,
      method: entity.method,
    );
  }
}
