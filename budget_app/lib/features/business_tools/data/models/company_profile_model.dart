import 'package:budget_app/features/business_tools/domain/entities/company_profile.dart';

class CompanyProfileModel extends CompanyProfile {
  const CompanyProfileModel({
    required super.id,
    required super.name,
    required super.address,
    super.taxId,
    super.logoPath,
    super.paymentInfo,
    required super.defaultVatRate,
    super.bankName,
    super.bankIban,
    super.bankBic,
    super.bankHolder,
    super.primaryColor,
    super.fontFamily,
    super.logoOnRight = false,
  });

  factory CompanyProfileModel.fromMap(Map<String, dynamic> map) {
    return CompanyProfileModel(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      taxId: map['tax_id'] as String?,
      logoPath: map['logo_path'] as String?,
      paymentInfo: map['payment_info'] as String?,
      defaultVatRate: (map['default_vat_rate'] as num).toDouble(),
      bankName: map['bank_name'] as String?,
      bankIban: map['bank_iban'] as String?,
      bankBic: map['bank_bic'] as String?,
      bankHolder: map['bank_holder'] as String?,
      primaryColor: map['primary_color'] as int?,
      fontFamily: map['font_family'] as String?,
      logoOnRight: (map['logo_on_right'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'tax_id': taxId,
      'logo_path': logoPath,
      'payment_info': paymentInfo,
      'default_vat_rate': defaultVatRate,
      'bank_name': bankName,
      'bank_iban': bankIban,
      'bank_bic': bankBic,
      'bank_holder': bankHolder,
      'primary_color': primaryColor,
      'font_family': fontFamily,
      'logo_on_right': logoOnRight ? 1 : 0,
    };
  }

  factory CompanyProfileModel.fromEntity(CompanyProfile entity) {
    return CompanyProfileModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      taxId: entity.taxId,
      logoPath: entity.logoPath,
      paymentInfo: entity.paymentInfo,
      defaultVatRate: entity.defaultVatRate,
      bankName: entity.bankName,
      bankIban: entity.bankIban,
      bankBic: entity.bankBic,
      bankHolder: entity.bankHolder,
      primaryColor: entity.primaryColor,
      fontFamily: entity.fontFamily,
      logoOnRight: entity.logoOnRight,
    );
  }
}
