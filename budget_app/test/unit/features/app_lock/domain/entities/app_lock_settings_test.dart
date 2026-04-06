import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/app_lock/domain/entities/app_lock_settings.dart';

void main() {
  group('AppLockSettings', () {
    test('should create with default values', () {
      const settings = AppLockSettings();

      expect(settings.isEnabled, false);
      expect(settings.authMethod, AuthMethod.pin);
      expect(settings.lastBackgroundTime, isNull);
    });

    test('should create with custom values', () {
      final lastBg = DateTime(2024, 1, 1);
      final settings = AppLockSettings(
        isEnabled: true,
        authMethod: AuthMethod.biometrics,
        lastBackgroundTime: lastBg,
      );

      expect(settings.isEnabled, true);
      expect(settings.authMethod, AuthMethod.biometrics);
      expect(settings.lastBackgroundTime, lastBg);
    });

    test('copyWith should update isEnabled', () {
      const original = AppLockSettings(isEnabled: false);
      final copied = original.copyWith(isEnabled: true);

      expect(copied.isEnabled, true);
      expect(copied.authMethod, AuthMethod.pin);
    });

    test('copyWith should update authMethod', () {
      const original = AppLockSettings(authMethod: AuthMethod.pin);
      final copied = original.copyWith(authMethod: AuthMethod.biometrics);

      expect(copied.authMethod, AuthMethod.biometrics);
      expect(copied.isEnabled, false);
    });

    test('copyWith should update lastBackgroundTime', () {
      const original = AppLockSettings();
      final newTime = DateTime(2024, 6, 15);
      final copied = original.copyWith(lastBackgroundTime: newTime);

      expect(copied.lastBackgroundTime, newTime);
    });

    test('props should contain all fields', () {
      final settings = AppLockSettings(
        isEnabled: true,
        authMethod: AuthMethod.biometrics,
        lastBackgroundTime: DateTime(2024, 1, 1),
      );

      expect(settings.props.length, 3);
    });

    test('two settings with same values should be equal', () {
      const settings1 = AppLockSettings(
        isEnabled: true,
        authMethod: AuthMethod.pin,
      );
      const settings2 = AppLockSettings(
        isEnabled: true,
        authMethod: AuthMethod.pin,
      );

      expect(settings1, equals(settings2));
    });
  });

  group('AuthMethod', () {
    test('should have correct values', () {
      expect(AuthMethod.values.length, 2);
      expect(AuthMethod.pin.index, 0);
      expect(AuthMethod.biometrics.index, 1);
    });
  });
}
