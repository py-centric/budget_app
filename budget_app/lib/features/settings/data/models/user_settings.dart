import '../../domain/entities/user_settings.dart' as domain;

/// Data-layer model for user settings.
/// Extends the domain entity to add serialization support.
class UserSettings extends domain.UserSettings {
  const UserSettings({
    super.weekStartDay = 1,
    super.defaultProjectionHorizon = 'MONTH',
    super.currencyCode = 'USD',
    super.themeMode = 'system',
    super.seedColor = 0xFF4CAF50,
    super.incomeColor = 0xFF4CAF50,
    super.expenseColor = 0xFFF44336,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      weekStartDay: map['weekStartDay'] as int? ?? 1,
      defaultProjectionHorizon:
          map['defaultProjectionHorizon'] as String? ?? 'MONTH',
      currencyCode: map['currencyCode'] as String? ?? 'USD',
      themeMode: map['themeMode'] as String? ?? 'system',
      seedColor: map['seedColor'] as int? ?? 0xFF4CAF50,
      incomeColor: map['incomeColor'] as int? ?? 0xFF4CAF50,
      expenseColor: map['expenseColor'] as int? ?? 0xFFF44336,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weekStartDay': weekStartDay,
      'defaultProjectionHorizon': defaultProjectionHorizon,
      'currencyCode': currencyCode,
      'themeMode': themeMode,
      'seedColor': seedColor,
      'incomeColor': incomeColor,
      'expenseColor': expenseColor,
    };
  }

  @override
  UserSettings copyWith({
    int? weekStartDay,
    String? defaultProjectionHorizon,
    String? currencyCode,
    String? themeMode,
    int? seedColor,
    int? incomeColor,
    int? expenseColor,
  }) {
    return UserSettings(
      weekStartDay: weekStartDay ?? this.weekStartDay,
      defaultProjectionHorizon:
          defaultProjectionHorizon ?? this.defaultProjectionHorizon,
      currencyCode: currencyCode ?? this.currencyCode,
      themeMode: themeMode ?? this.themeMode,
      seedColor: seedColor ?? this.seedColor,
      incomeColor: incomeColor ?? this.incomeColor,
      expenseColor: expenseColor ?? this.expenseColor,
    );
  }
}
