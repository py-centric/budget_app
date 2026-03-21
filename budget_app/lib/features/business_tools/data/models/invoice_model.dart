import 'package:budget_app/features/business_tools/domain/entities/invoice.dart';

class InvoiceModel extends Invoice {
  const InvoiceModel({
    required super.id,
    required super.profileId,
    required super.invoiceNumber,
    required super.date,
    required super.clientName,
    required super.clientDetails,
    required super.status,
    required super.subTotal,
    required super.taxTotal,
    required super.grandTotal,
    required super.balanceDue,
    super.notes,
    super.bankName,
    super.bankIban,
    super.bankBic,
    super.bankHolder,
    super.clientId,
  });

  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      id: map['id'] as String,
      profileId: map['profile_id'] as String,
      invoiceNumber: map['invoice_number'] as String,
      date: DateTime.parse(map['date'] as String),
      clientName: map['client_name'] as String,
      clientDetails: map['client_details'] as String,
      status: InvoiceStatus.values.firstWhere((e) => e.toString() == map['status']),
      subTotal: (map['sub_total'] as num).toDouble(),
      taxTotal: (map['tax_total'] as num).toDouble(),
      grandTotal: (map['grand_total'] as num).toDouble(),
      balanceDue: (map['balance_due'] as num).toDouble(),
      notes: map['notes'] as String?,
      bankName: map['bank_name'] as String?,
      bankIban: map['bank_iban'] as String?,
      bankBic: map['bank_bic'] as String?,
      bankHolder: map['bank_holder'] as String?,
      clientId: map['client_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'invoice_number': invoiceNumber,
      'date': date.toIso8601String(),
      'client_name': clientName,
      'client_details': clientDetails,
      'status': status.toString(),
      'sub_total': subTotal,
      'tax_total': taxTotal,
      'grand_total': grandTotal,
      'balance_due': balanceDue,
      'notes': notes,
      'bank_name': bankName,
      'bank_iban': bankIban,
      'bank_bic': bankBic,
      'bank_holder': bankHolder,
      'client_id': clientId,
    };
  }

  factory InvoiceModel.fromEntity(Invoice entity) {
    return InvoiceModel(
      id: entity.id,
      profileId: entity.profileId,
      invoiceNumber: entity.invoiceNumber,
      date: entity.date,
      clientName: entity.clientName,
      clientDetails: entity.clientDetails,
      status: entity.status,
      subTotal: entity.subTotal,
      taxTotal: entity.taxTotal,
      grandTotal: entity.grandTotal,
      balanceDue: entity.balanceDue,
      notes: entity.notes,
      bankName: entity.bankName,
      bankIban: entity.bankIban,
      bankBic: entity.bankBic,
      bankHolder: entity.bankHolder,
      clientId: entity.clientId,
    );
  }
}
