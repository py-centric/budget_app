import '../../domain/entities/user_settings.dart' as domain;

/// Data-layer model for user settings within the budget feature.
/// Extends the domain entity to add serialization support.
class UserSettings extends domain.UserSettings {
  const UserSettings({
    super.weekStartDay = 1,
    super.defaultProjectionHorizon = 'MONTH',
    super.currencyCode = 'USD',
    super.themeMode = 'system',
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      weekStartDay: map['weekStartDay'] as int? ?? 1,
      defaultProjectionHorizon:
          map['defaultProjectionHorizon'] as String? ?? 'MONTH',
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
      defaultProjectionHorizon:
          defaultProjectionHorizon ?? this.defaultProjectionHorizon,
      currencyCode: currencyCode ?? this.currencyCode,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
