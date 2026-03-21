import 'package:budget_app/features/business_tools/domain/entities/client.dart';

class ClientModel extends Client {
  const ClientModel({
    required super.id,
    required super.name,
    required super.address,
    super.taxId,
    super.primaryContact,
    super.email,
    super.phone,
    super.website,
    super.industry,
    super.notes,
  });

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      taxId: map['tax_id'] as String?,
      primaryContact: map['primary_contact'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      website: map['website'] as String?,
      industry: map['industry'] as String?,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'tax_id': taxId,
      'primary_contact': primaryContact,
      'email': email,
      'phone': phone,
      'website': website,
      'industry': industry,
      'notes': notes,
    };
  }

  factory ClientModel.fromEntity(Client entity) {
    return ClientModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      taxId: entity.taxId,
      primaryContact: entity.primaryContact,
      email: entity.email,
      phone: entity.phone,
      website: entity.website,
      industry: entity.industry,
      notes: entity.notes,
    );
  }
}
