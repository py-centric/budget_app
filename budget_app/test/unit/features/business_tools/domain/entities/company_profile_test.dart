import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/business_tools/domain/entities/company_profile.dart';

void main() {
  group('CompanyProfile', () {
    test('should create CompanyProfile with required fields', () {
      const profile = CompanyProfile(
        id: '1',
        name: 'Test Company',
        address: '123 Test St',
      );

      expect(profile.id, '1');
      expect(profile.name, 'Test Company');
      expect(profile.address, '123 Test St');
      expect(profile.taxId, isNull);
      expect(profile.logoPath, isNull);
      expect(profile.defaultVatRate, 0.0);
      expect(profile.logoOnRight, false);
    });

    test('should create CompanyProfile with all fields', () {
      const profile = CompanyProfile(
        id: '1',
        name: 'Test Company',
        address: '123 Test St',
        taxId: 'TAX123456',
        logoPath: '/path/to/logo.png',
        paymentInfo: 'Payment terms: Net 30',
        defaultVatRate: 20.0,
        bankName: 'Test Bank',
        bankIban: 'GB82WEST12345698765432',
        bankBic: 'WESTGB22',
        bankHolder: 'Test Company Ltd',
        primaryColor: 0xFF0000FF,
        fontFamily: 'Roboto',
        logoOnRight: true,
      );

      expect(profile.id, '1');
      expect(profile.name, 'Test Company');
      expect(profile.taxId, 'TAX123456');
      expect(profile.logoPath, '/path/to/logo.png');
      expect(profile.paymentInfo, 'Payment terms: Net 30');
      expect(profile.defaultVatRate, 20.0);
      expect(profile.bankName, 'Test Bank');
      expect(profile.bankIban, 'GB82WEST12345698765432');
      expect(profile.bankBic, 'WESTGB22');
      expect(profile.bankHolder, 'Test Company Ltd');
      expect(profile.primaryColor, 0xFF0000FF);
      expect(profile.fontFamily, 'Roboto');
      expect(profile.logoOnRight, true);
    });

    test('copyWith should create a copy with updated fields', () {
      const original = CompanyProfile(
        id: '1',
        name: 'Original Company',
        address: 'Original Address',
        defaultVatRate: 15.0,
      );

      final copied = original.copyWith(
        name: 'New Company',
        defaultVatRate: 25.0,
        logoOnRight: true,
      );

      expect(copied.id, '1');
      expect(copied.name, 'New Company');
      expect(copied.address, 'Original Address');
      expect(copied.defaultVatRate, 25.0);
      expect(copied.logoOnRight, true);
    });

    test('props should contain all fields', () {
      const profile = CompanyProfile(
        id: '1',
        name: 'Test Company',
        address: 'Test Address',
        taxId: 'TAX123',
        defaultVatRate: 20.0,
        logoOnRight: true,
      );

      expect(profile.props, [
        '1',
        'Test Company',
        'Test Address',
        'TAX123',
        null,
        null,
        20.0,
        null,
        null,
        null,
        null,
        null,
        null,
        true,
      ]);
    });

    test('two profiles with same values should be equal', () {
      const profile1 = CompanyProfile(
        id: '1',
        name: 'Test Company',
        address: 'Test Address',
      );

      const profile2 = CompanyProfile(
        id: '1',
        name: 'Test Company',
        address: 'Test Address',
      );

      expect(profile1, equals(profile2));
    });

    test('two profiles with different values should not be equal', () {
      const profile1 = CompanyProfile(
        id: '1',
        name: 'Company A',
        address: 'Address A',
      );

      const profile2 = CompanyProfile(
        id: '2',
        name: 'Company B',
        address: 'Address B',
      );

      expect(profile1, isNot(equals(profile2)));
    });
  });
}
