import 'package:equatable/equatable.dart';

class Client extends Equatable {
  final String id;
  final String name;
  final String address;
  final String? taxId;
  final String? primaryContact;
  final String? email;
  final String? phone;
  final String? website;
  final String? industry;
  final String? notes;

  const Client({
    required this.id,
    required this.name,
    required this.address,
    this.taxId,
    this.primaryContact,
    this.email,
    this.phone,
    this.website,
    this.industry,
    this.notes,
  });

  Client copyWith({
    String? id,
    String? name,
    String? address,
    String? taxId,
    String? primaryContact,
    String? email,
    String? phone,
    String? website,
    String? industry,
    String? notes,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      taxId: taxId ?? this.taxId,
      primaryContact: primaryContact ?? this.primaryContact,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      industry: industry ?? this.industry,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        taxId,
        primaryContact,
        email,
        phone,
        website,
        industry,
        notes,
      ];
}
