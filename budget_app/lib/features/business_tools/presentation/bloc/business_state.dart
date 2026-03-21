import 'package:equatable/equatable.dart';
import 'package:budget_app/features/business_tools/domain/entities/company_profile.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice_item.dart';
import 'package:budget_app/features/business_tools/domain/entities/client.dart';

import 'package:budget_app/features/business_tools/domain/entities/received_invoice.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice_summary.dart';
import 'package:flutter/material.dart';

enum BusinessStatus { initial, loading, success, failure }

class BusinessState extends Equatable {
  final BusinessStatus status;
  final List<CompanyProfile> profiles;
  final List<Client> clients;
  final List<Invoice> invoices;
  final List<ReceivedInvoice> receivedInvoices;
  final InvoiceSummary? summary;
  final DateTimeRange? filterRange;
  final String? errorMessage;
  final Invoice? lastSavedInvoice;
  final List<InvoiceItem>? lastSavedItems;

  const BusinessState({
    this.status = BusinessStatus.initial,
    this.profiles = const [],
    this.clients = const [],
    this.invoices = const [],
    this.receivedInvoices = const [],
    this.summary,
    this.filterRange,
    this.errorMessage,
    this.lastSavedInvoice,
    this.lastSavedItems,
  });

  BusinessState copyWith({
    BusinessStatus? status,
    List<CompanyProfile>? profiles,
    List<Client>? clients,
    List<Invoice>? invoices,
    List<ReceivedInvoice>? receivedInvoices,
    InvoiceSummary? summary,
    DateTimeRange? filterRange,
    String? errorMessage,
    Invoice? lastSavedInvoice,
    List<InvoiceItem>? lastSavedItems,
    bool clearLastSavedInvoice = false,
  }) {
    return BusinessState(
      status: status ?? this.status,
      profiles: profiles ?? this.profiles,
      clients: clients ?? this.clients,
      invoices: invoices ?? this.invoices,
      receivedInvoices: receivedInvoices ?? this.receivedInvoices,
      summary: summary ?? this.summary,
      filterRange: filterRange ?? this.filterRange,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSavedInvoice: clearLastSavedInvoice ? null : (lastSavedInvoice ?? this.lastSavedInvoice),
      lastSavedItems: clearLastSavedInvoice ? null : (lastSavedItems ?? this.lastSavedItems),
    );
  }

  @override
  List<Object?> get props => [
        status,
        profiles,
        clients,
        invoices,
        receivedInvoices,
        summary,
        filterRange,
        errorMessage,
        lastSavedInvoice,
        lastSavedItems,
      ];
}
