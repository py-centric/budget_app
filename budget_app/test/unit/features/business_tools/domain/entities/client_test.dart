import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/business_tools/domain/entities/client.dart';

void main() {
  group('Client', () {
    test('should create Client with required fields', () {
      const client = Client(
        id: '1',
        name: 'Test Client',
        address: '123 Test St',
      );

      expect(client.id, '1');
      expect(client.name, 'Test Client');
      expect(client.address, '123 Test St');
      expect(client.taxId, isNull);
      expect(client.primaryContact, isNull);
      expect(client.email, isNull);
    });

    test('should create Client with all fields', () {
      const client = Client(
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

      expect(client.id, '1');
      expect(client.name, 'Test Client');
      expect(client.taxId, 'TAX123');
      expect(client.primaryContact, 'John Doe');
      expect(client.email, 'john@test.com');
      expect(client.phone, '+1234567890');
      expect(client.website, 'https://test.com');
      expect(client.industry, 'Technology');
      expect(client.notes, 'Test notes');
    });

    test('copyWith should create a copy with updated fields', () {
      const original = Client(
        id: '1',
        name: 'Original Name',
        address: 'Original Address',
      );

      final copied = original.copyWith(name: 'New Name');

      expect(copied.id, '1');
      expect(copied.name, 'New Name');
      expect(copied.address, 'Original Address');
    });

    test('props should contain all fields', () {
      const client = Client(
        id: '1',
        name: 'Test Client',
        address: '123 Test St',
        taxId: 'TAX123',
      );

      expect(client.props, [
        '1',
        'Test Client',
        '123 Test St',
        'TAX123',
        null,
        null,
        null,
        null,
        null,
        null,
      ]);
    });

    test('two clients with same values should be equal', () {
      const client1 = Client(
        id: '1',
        name: 'Test Client',
        address: '123 Test St',
      );

      const client2 = Client(
        id: '1',
        name: 'Test Client',
        address: '123 Test St',
      );

      expect(client1, equals(client2));
    });

    test('two clients with different values should not be equal', () {
      const client1 = Client(
        id: '1',
        name: 'Test Client',
        address: '123 Test St',
      );

      const client2 = Client(
        id: '2',
        name: 'Test Client',
        address: '123 Test St',
      );

      expect(client1, isNot(equals(client2)));
    });
  });
}
