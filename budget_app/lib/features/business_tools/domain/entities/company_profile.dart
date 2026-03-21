import 'package:equatable/equatable.dart';

class CompanyProfile extends Equatable {
  final String id;
  final String name;
  final String address;
  final String? taxId;
  final String? logoPath;
  final String? paymentInfo;
  final double defaultVatRate;
  final String? bankName;
  final String? bankIban;
  final String? bankBic;
  final String? bankHolder;
  final int? primaryColor;
  final String? fontFamily;
  final bool logoOnRight;

  const CompanyProfile({
    required this.id,
    required this.name,
    required this.address,
    this.taxId,
    this.logoPath,
    this.paymentInfo,
    this.defaultVatRate = 0.0,
    this.bankName,
    this.bankIban,
    this.bankBic,
    this.bankHolder,
    this.primaryColor,
    this.fontFamily,
    this.logoOnRight = false,
  });

  CompanyProfile copyWith({
    String? id,
    String? name,
    String? address,
    String? taxId,
    String? logoPath,
    String? paymentInfo,
    double? defaultVatRate,
    String? bankName,
    String? bankIban,
    String? bankBic,
    String? bankHolder,
    int? primaryColor,
    String? fontFamily,
    bool? logoOnRight,
  }) {
    return CompanyProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      taxId: taxId ?? this.taxId,
      logoPath: logoPath ?? this.logoPath,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      defaultVatRate: defaultVatRate ?? this.defaultVatRate,
      bankName: bankName ?? this.bankName,
      bankIban: bankIban ?? this.bankIban,
      bankBic: bankBic ?? this.bankBic,
      bankHolder: bankHolder ?? this.bankHolder,
      primaryColor: primaryColor ?? this.primaryColor,
      fontFamily: fontFamily ?? this.fontFamily,
      logoOnRight: logoOnRight ?? this.logoOnRight,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        taxId,
        logoPath,
        paymentInfo,
        defaultVatRate,
        bankName,
        bankIban,
        bankBic,
        bankHolder,
        primaryColor,
        fontFamily,
        logoOnRight,
      ];
}
