import 'package:budget_app/features/business_tools/domain/entities/invoice_item.dart';

class InvoiceItemModel extends InvoiceItem {
  const InvoiceItemModel({
    required super.id,
    required super.invoiceId,
    required super.description,
    required super.quantity,
    required super.rate,
    required super.taxRate,
    required super.total,
  });

  factory InvoiceItemModel.fromMap(Map<String, dynamic> map) {
    return InvoiceItemModel(
      id: map['id'] as String,
      invoiceId: map['invoice_id'] as String,
      description: map['description'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      rate: (map['rate'] as num).toDouble(),
      taxRate: (map['tax_rate'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'description': description,
      'quantity': quantity,
      'rate': rate,
      'tax_rate': taxRate,
      'total': total,
    };
  }

  factory InvoiceItemModel.fromEntity(InvoiceItem entity) {
    return InvoiceItemModel(
      id: entity.id,
      invoiceId: entity.invoiceId,
      description: entity.description,
      quantity: entity.quantity,
      rate: entity.rate,
      taxRate: entity.taxRate,
      total: entity.total,
    );
  }
}
