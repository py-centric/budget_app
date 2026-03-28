import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/budget/data/models/user_settings.dart';

void main() {
  group('UserSettings', () {
    test('should create with default values', () {
      final settings = UserSettings();

      expect(settings.weekStartDay, 1);
      expect(settings.defaultProjectionHorizon, 'MONTH');
      expect(settings.currencyCode, 'USD');
      expect(settings.themeMode, 'system');
    });

    test('should create from map', () {
      final map = {
        'weekStartDay': 0,
        'defaultProjectionHorizon': '90_DAYS',
        'currencyCode': 'EUR',
        'themeMode': 'dark',
      };

      final settings = UserSettings.fromMap(map);

      expect(settings.weekStartDay, 0);
      expect(settings.defaultProjectionHorizon, '90_DAYS');
      expect(settings.currencyCode, 'EUR');
      expect(settings.themeMode, 'dark');
    });

    test('should convert to map', () {
      final settings = UserSettings(
        weekStartDay: 0,
        defaultProjectionHorizon: 'YEAR',
        currencyCode: 'GBP',
        themeMode: 'light',
      );

      final map = settings.toMap();

      expect(map['weekStartDay'], 0);
      expect(map['defaultProjectionHorizon'], 'YEAR');
      expect(map['currencyCode'], 'GBP');
      expect(map['themeMode'], 'light');
    });

    test('should copy with new values', () {
      final settings = UserSettings();
      final newSettings = settings.copyWith(
        currencyCode: 'JPY',
        themeMode: 'dark',
      );

      expect(newSettings.currencyCode, 'JPY');
      expect(newSettings.themeMode, 'dark');
      expect(newSettings.weekStartDay, settings.weekStartDay);
    });
  });
}
