import 'package:equatable/equatable.dart';
import 'package:budget_app/features/business_tools/domain/entities/company_profile.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice_item.dart';
import 'package:budget_app/features/business_tools/domain/entities/invoice_payment.dart';
import 'package:budget_app/features/business_tools/domain/entities/client.dart';
import 'package:budget_app/features/business_tools/domain/entities/received_invoice.dart';
import 'package:flutter/material.dart';

abstract class BusinessEvent extends Equatable {
  const BusinessEvent();
  @override
  List<Object?> get props => [];
}

class LoadBusinessData extends BusinessEvent {}

// Profiles
class SaveProfile extends BusinessEvent {
  final CompanyProfile profile;
  const SaveProfile(this.profile);
  @override
  List<Object> get props => [profile];
}

class DeleteProfile extends BusinessEvent {
  final String id;
  const DeleteProfile(this.id);
  @override
  List<Object> get props => [id];
}

// Clients
class SaveClient extends BusinessEvent {
  final Client client;
  const SaveClient(this.client);
  @override
  List<Object> get props => [client];
}

class DeleteClient extends BusinessEvent {
  final String id;
  const DeleteClient(this.id);
  @override
  List<Object> get props => [id];
}

// Received Invoices
class SaveReceivedInvoice extends BusinessEvent {
  final ReceivedInvoice invoice;
  const SaveReceivedInvoice(this.invoice);
  @override
  List<Object> get props => [invoice];
}

class DeleteReceivedInvoice extends BusinessEvent {
  final String id;
  const DeleteReceivedInvoice(this.id);
  @override
  List<Object> get props => [id];
}

class FilterInvoices extends BusinessEvent {
  final DateTimeRange range;
  const FilterInvoices(this.range);
  @override
  List<Object> get props => [range];
}

// Invoices
class SaveInvoice extends BusinessEvent {
  final Invoice invoice;
  final List<InvoiceItem> items;
  const SaveInvoice(this.invoice, this.items);
  @override
  List<Object> get props => [invoice, items];
}

class CloneInvoiceEvent extends BusinessEvent {
  final String id;
  const CloneInvoiceEvent(this.id);
  @override
  List<Object> get props => [id];
}

class DeleteInvoice extends BusinessEvent {
  final String id;
  const DeleteInvoice(this.id);
  @override
  List<Object> get props => [id];
}

class AddPayment extends BusinessEvent {
  final InvoicePayment payment;
  const AddPayment(this.payment);
  @override
  List<Object> get props => [payment];
}

class ClearLastSavedInvoice extends BusinessEvent {}
