import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/business_tools/data/models/company_profile_model.dart';
import 'package:budget_app/features/business_tools/domain/entities/company_profile.dart';

void main() {
  group('CompanyProfileModel', () {
    test('should create CompanyProfileModel with required fields', () {
      const model = CompanyProfileModel(
        id: '1',
        name: 'Test Company',
        address: '123 Test St',
        defaultVatRate: 20.0,
      );

      expect(model.id, '1');
      expect(model.name, 'Test Company');
      expect(model.address, '123 Test St');
      expect(model.defaultVatRate, 20.0);
      expect(model.logoOnRight, false);
    });

    test('should create CompanyProfileModel fromMap', () {
      final map = {
        'id': '1',
        'name': 'Map Company',
        'address': '456 Map Ave',
        'tax_id': 'TAX123',
        'logo_path': '/path/to/logo.png',
        'payment_info': 'Net 30',
        'default_vat_rate': 15.0,
        'bank_name': 'Test Bank',
        'bank_iban': 'GB82WEST12345698765432',
        'bank_bic': 'WESTGB22',
        'bank_holder': 'Test Holder',
        'primary_color': 0xFF0000FF,
        'font_family': 'Roboto',
        'logo_on_right': 1,
      };

      final model = CompanyProfileModel.fromMap(map);

      expect(model.id, '1');
      expect(model.name, 'Map Company');
      expect(model.defaultVatRate, 15.0);
      expect(model.bankName, 'Test Bank');
      expect(model.logoOnRight, true);
    });

    test('toMap should return correct map', () {
      const model = CompanyProfileModel(
        id: '1',
        name: 'Test Company',
        address: 'Test Address',
        defaultVatRate: 25.0,
        logoOnRight: true,
      );

      final map = model.toMap();

      expect(map['id'], '1');
      expect(map['name'], 'Test Company');
      expect(map['default_vat_rate'], 25.0);
      expect(map['logo_on_right'], 1);
    });

    test('fromEntity should create model from entity', () {
      const entity = CompanyProfile(
        id: '1',
        name: 'Entity Company',
        address: 'Entity Address',
        defaultVatRate: 18.0,
      );

      final model = CompanyProfileModel.fromEntity(entity);

      expect(model.id, '1');
      expect(model.name, 'Entity Company');
      expect(model.defaultVatRate, 18.0);
    });

    test('CompanyProfileModel should be a subtype of CompanyProfile', () {
      const model = CompanyProfileModel(
        id: '1',
        name: 'Test',
        address: 'Test',
        defaultVatRate: 20.0,
      );

      expect(model, isA<CompanyProfile>());
    });
  });
}
