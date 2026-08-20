import 'package:equatable/equatable.dart';

/// Domain entity for application-wide user settings.
/// Pure domain layer (no data-layer dependencies).
class UserSettings extends Equatable {
  final int weekStartDay;
  final String defaultProjectionHorizon;
  final String currencyCode;
  final String themeMode;
  final int seedColor;
  final int incomeColor;
  final int expenseColor;

  const UserSettings({
    this.weekStartDay = 1,
    this.defaultProjectionHorizon = 'MONTH',
    this.currencyCode = 'USD',
    this.themeMode = 'system',
    this.seedColor = 0xFF4CAF50,
    this.incomeColor = 0xFF4CAF50,
    this.expenseColor = 0xFFF44336,
  });

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

  @override
  List<Object?> get props => [
    weekStartDay,
    defaultProjectionHorizon,
    currencyCode,
    themeMode,
    seedColor,
    incomeColor,
    expenseColor,
  ];
}
