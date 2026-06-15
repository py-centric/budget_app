import 'package:equatable/equatable.dart';

/// Domain entity for application-wide user settings.
/// Pure domain layer — no data-layer dependencies.
class UserSettings extends Equatable {
  final int weekStartDay;
  final String defaultProjectionHorizon;
  final String currencyCode;
  final String themeMode;

  const UserSettings({
    this.weekStartDay = 1,
    this.defaultProjectionHorizon = 'MONTH',
    this.currencyCode = 'USD',
    this.themeMode = 'system',
  });

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

  @override
  List<Object?> get props => [
    weekStartDay,
    defaultProjectionHorizon,
    currencyCode,
    themeMode,
  ];
}
