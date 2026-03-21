import 'package:equatable/equatable.dart';

enum InvoiceStatus { draft, sent, paid }

class Invoice extends Equatable {
  final String id;
  final String profileId;
  final String invoiceNumber;
  final DateTime date;
  final String clientName;
  final String clientDetails;
  final InvoiceStatus status;
  final double subTotal;
  final double taxTotal;
  final double grandTotal;
  final double balanceDue;
  final String? notes;
  final String? bankName;
  final String? bankIban;
  final String? bankBic;
  final String? bankHolder;
  final String? clientId;

  const Invoice({
    required this.id,
    required this.profileId,
    required this.invoiceNumber,
    required this.date,
    required this.clientName,
    required this.clientDetails,
    required this.status,
    required this.subTotal,
    required this.taxTotal,
    required this.grandTotal,
    required this.balanceDue,
    this.notes,
    this.bankName,
    this.bankIban,
    this.bankBic,
    this.bankHolder,
    this.clientId,
  });

  Invoice copyWith({
    String? id,
    String? profileId,
    String? invoiceNumber,
    DateTime? date,
    String? clientName,
    String? clientDetails,
    InvoiceStatus? status,
    double? subTotal,
    double? taxTotal,
    double? grandTotal,
    double? balanceDue,
    String? notes,
    String? bankName,
    String? bankIban,
    String? bankBic,
    String? bankHolder,
    String? clientId,
  }) {
    return Invoice(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      date: date ?? this.date,
      clientName: clientName ?? this.clientName,
      clientDetails: clientDetails ?? this.clientDetails,
      status: status ?? this.status,
      subTotal: subTotal ?? this.subTotal,
      taxTotal: taxTotal ?? this.taxTotal,
      grandTotal: grandTotal ?? this.grandTotal,
      balanceDue: balanceDue ?? this.balanceDue,
      notes: notes ?? this.notes,
      bankName: bankName ?? this.bankName,
      bankIban: bankIban ?? this.bankIban,
      bankBic: bankBic ?? this.bankBic,
      bankHolder: bankHolder ?? this.bankHolder,
      clientId: clientId ?? this.clientId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        profileId,
        invoiceNumber,
        date,
        clientName,
        clientDetails,
        status,
        subTotal,
        taxTotal,
        grandTotal,
        balanceDue,
        notes,
        bankName,
        bankIban,
        bankBic,
        bankHolder,
        clientId,
      ];
}
