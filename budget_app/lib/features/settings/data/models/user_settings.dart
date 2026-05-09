import 'package:equatable/equatable.dart';

class UserSettings extends Equatable {
  final int weekStartDay;
  final String defaultProjectionHorizon;
  final String currencyCode;
  final String themeMode;

  const UserSettings({
    this.weekStartDay = 1, // 1 = Monday
    this.defaultProjectionHorizon = 'MONTH', // e.g. "MONTH", "30_DAYS", "90_DAYS"
    this.currencyCode = 'USD',
    this.themeMode = 'system',
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      weekStartDay: map['weekStartDay'] as int? ?? 1,
      defaultProjectionHorizon: map['defaultProjectionHorizon'] as String? ?? 'MONTH',
      currencyCode: map['currencyCode'] as String? ?? 'USD',
      themeMode: map['themeMode'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weekStartDay': weekStartDay,
      'defaultProjectionHorizon': defaultProjectionHorizon,
      'currencyCode': currencyCode,
      'themeMode': themeMode,
    };
  }

  UserSettings copyWith({
    int? weekStartDay,
    String? defaultProjectionHorizon,
    String? currencyCode,
    String? themeMode,
  }) {
    return UserSettings(
      weekStartDay: weekStartDay ?? this.weekStartDay,
      defaultProjectionHorizon: defaultProjectionHorizon ?? this.defaultProjectionHorizon,
      currencyCode: currencyCode ?? this.currencyCode,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [weekStartDay, defaultProjectionHorizon, currencyCode, themeMode];
}
