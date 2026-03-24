import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/app_lock/domain/entities/app_lock_settings.dart';

void main() {
  group('AppLockSettings', () {
    test('creates with default values', () {
      const settings = AppLockSettings();

      expect(settings.isEnabled, false);
      expect(settings.authMethod, AuthMethod.pin);
      expect(settings.lastBackgroundTime, null);
    });

    test('creates with custom values', () {
      final now = DateTime.now();
      final settings = AppLockSettings(
        isEnabled: true,
        authMethod: AuthMethod.biometrics,
        lastBackgroundTime: now,
      );

      expect(settings.isEnabled, true);
      expect(settings.authMethod, AuthMethod.biometrics);
      expect(settings.lastBackgroundTime, now);
    });

    test('copyWith creates new instance with updated values', () {
      const original = AppLockSettings();
      final updated = original.copyWith(
        isEnabled: true,
        authMethod: AuthMethod.biometrics,
      );

      expect(updated.isEnabled, true);
      expect(updated.authMethod, AuthMethod.biometrics);
      expect(original.isEnabled, false);
    });

    test('copyWith preserves unchanged values', () {
      final now = DateTime.now();
      final original = AppLockSettings(
        isEnabled: true,
        lastBackgroundTime: now,
      );

      final updated = original.copyWith(isEnabled: false);

      expect(updated.isEnabled, false);
      expect(updated.authMethod, AuthMethod.pin);
      expect(updated.lastBackgroundTime, now);
    });

    test('equality works correctly', () {
      const settings1 = AppLockSettings(isEnabled: true);
      const settings2 = AppLockSettings(isEnabled: true);
      const settings3 = AppLockSettings(isEnabled: false);

      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
    });

    test('props includes all fields', () {
      const settings = AppLockSettings();
      expect(settings.props.length, 3);
    });
  });

  group('AuthMethod', () {
    test('has correct values', () {
      expect(AuthMethod.values.length, 2);
      expect(AuthMethod.values, contains(AuthMethod.pin));
      expect(AuthMethod.values, contains(AuthMethod.biometrics));
    });
  });
}
