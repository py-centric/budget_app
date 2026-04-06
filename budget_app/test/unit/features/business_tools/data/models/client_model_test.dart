import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/business_tools/data/models/client_model.dart';
import 'package:budget_app/features/business_tools/domain/entities/client.dart';

void main() {
  group('ClientModel', () {
    test('should create ClientModel with required fields', () {
      const model = ClientModel(
        id: '1',
        name: 'Test Client',
        address: '123 Test St',
      );

      expect(model.id, '1');
      expect(model.name, 'Test Client');
      expect(model.address, '123 Test St');
      expect(model.taxId, isNull);
    });

    test('should create ClientModel with all fields', () {
      const model = ClientModel(
        id: '1',
        name: 'Test Client',
        address: '123 Test St',
        taxId: 'TAX123',
        primaryContact: 'John Doe',
        email: 'john@test.com',
        phone: '+1234567890',
        website: 'https://test.com',
        industry: 'Technology',
        notes: 'Test notes',
      );

      expect(model.taxId, 'TAX123');
      expect(model.primaryContact, 'John Doe');
      expect(model.email, 'john@test.com');
    });

    test('should create ClientModel fromMap', () {
      final map = {
        'id': '1',
        'name': 'Map Client',
        'address': '456 Map Ave',
        'tax_id': 'MAP123',
        'primary_contact': 'Jane',
        'email': 'jane@test.com',
        'phone': '+0987654321',
        'website': 'https://map.com',
        'industry': 'Finance',
        'notes': 'Map notes',
      };

      final model = ClientModel.fromMap(map);

      expect(model.id, '1');
      expect(model.name, 'Map Client');
      expect(model.address, '456 Map Ave');
      expect(model.taxId, 'MAP123');
      expect(model.email, 'jane@test.com');
    });

    test('toMap should return correct map', () {
      const model = ClientModel(
        id: '1',
        name: 'Test Client',
        address: 'Test Address',
        taxId: 'TAX123',
      );

      final map = model.toMap();

      expect(map['id'], '1');
      expect(map['name'], 'Test Client');
      expect(map['address'], 'Test Address');
      expect(map['tax_id'], 'TAX123');
    });

    test('fromEntity should create model from entity', () {
      const entity = Client(
        id: '1',
        name: 'Entity Client',
        address: 'Entity Address',
        taxId: 'ENTITY123',
      );

      final model = ClientModel.fromEntity(entity);

      expect(model.id, '1');
      expect(model.name, 'Entity Client');
      expect(model.taxId, 'ENTITY123');
    });

    test('ClientModel should be a subtype of Client', () {
      const model = ClientModel(id: '1', name: 'Test', address: 'Test');

      expect(model, isA<Client>());
    });
  });
}
