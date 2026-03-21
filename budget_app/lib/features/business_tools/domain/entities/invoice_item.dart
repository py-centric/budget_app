import 'package:equatable/equatable.dart';

class InvoiceItem extends Equatable {
  final String id;
  final String invoiceId;
  final String description;
  final double quantity;
  final double rate;
  final double taxRate;
  final double total;

  const InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.description,
    required this.quantity,
    required this.rate,
    required this.taxRate,
    required this.total,
  });

  InvoiceItem copyWith({
    String? id,
    String? invoiceId,
    String? description,
    double? quantity,
    double? rate,
    double? taxRate,
    double? total,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      taxRate: taxRate ?? this.taxRate,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [id, invoiceId, description, quantity, rate, taxRate, total];
}
