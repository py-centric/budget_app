import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:budget_app/features/app_lock/data/repositories/app_lock_repository_impl.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

void main() {
  late AuthServiceImpl authService;
  late MockFlutterSecureStorage mockStorage;
  late MockLocalAuthentication mockLocalAuth;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    mockLocalAuth = MockLocalAuthentication();
    authService = AuthServiceImpl(
      secureStorage: mockStorage,
      localAuth: mockLocalAuth,
    );
  });

  setUpAll(() {
    registerFallbackValue(
      const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
    );
  });

  group('AuthServiceImpl', () {
    group('isBiometricAvailable', () {
      test('returns true when biometrics are available', () async {
        when(
          () => mockLocalAuth.canCheckBiometrics,
        ).thenAnswer((_) async => true);
        when(
          () => mockLocalAuth.isDeviceSupported(),
        ).thenAnswer((_) async => true);

        final result = await authService.isBiometricAvailable();

        expect(result, true);
      });

      test('returns false when canCheckBiometrics is false', () async {
        when(
          () => mockLocalAuth.canCheckBiometrics,
        ).thenAnswer((_) async => false);

        final result = await authService.isBiometricAvailable();

        expect(result, false);
      });

      test('returns false when isDeviceSupported is false', () async {
        when(
          () => mockLocalAuth.canCheckBiometrics,
        ).thenAnswer((_) async => true);
        when(
          () => mockLocalAuth.isDeviceSupported(),
        ).thenAnswer((_) async => false);

        final result = await authService.isBiometricAvailable();

        expect(result, false);
      });

      test('returns false on exception', () async {
        when(
          () => mockLocalAuth.canCheckBiometrics,
        ).thenThrow(Exception('Error'));

        final result = await authService.isBiometricAvailable();

        expect(result, false);
      });
    });

    group('authenticateWithBiometrics', () {
      test('returns true when authentication succeeds', () async {
        when(
          () => mockLocalAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          ),
        ).thenAnswer((_) async => true);

        final result = await authService.authenticateWithBiometrics();

        expect(result, true);
      });

      test('returns false when authentication fails', () async {
        when(
          () => mockLocalAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          ),
        ).thenAnswer((_) async => false);

        final result = await authService.authenticateWithBiometrics();

        expect(result, false);
      });

      test('returns false on exception', () async {
        when(
          () => mockLocalAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          ),
        ).thenThrow(Exception('Error'));

        final result = await authService.authenticateWithBiometrics();

        expect(result, false);
      });
    });

    group('verifyPin', () {
      test('returns true when PIN matches', () async {
        when(
          () => mockStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => '1234');

        final result = await authService.verifyPin('1234');

        expect(result, true);
      });

      test('returns false when PIN does not match', () async {
        when(
          () => mockStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => '1234');

        final result = await authService.verifyPin('5678');

        expect(result, false);
      });

      test('returns false when no PIN stored', () async {
        when(
          () => mockStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => null);

        final result = await authService.verifyPin('1234');

        expect(result, false);
      });
    });

    group('savePin', () {
      test('saves PIN to storage', () async {
        when(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        await authService.savePin('1234');

        verify(
          () => mockStorage.write(key: 'app_lock_pin', value: '1234'),
        ).called(1);
      });
    });

    group('hasPin', () {
      test('returns true when PIN exists', () async {
        when(
          () => mockStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => '1234');

        final result = await authService.hasPin();

        expect(result, true);
      });

      test('returns false when no PIN', () async {
        when(
          () => mockStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => null);

        final result = await authService.hasPin();

        expect(result, false);
      });

      test('returns false when PIN is empty', () async {
        when(
          () => mockStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => '');

        final result = await authService.hasPin();

        expect(result, false);
      });
    });

    group('clearPin', () {
      test('deletes PIN from storage', () async {
        when(
          () => mockStorage.delete(key: any(named: 'key')),
        ).thenAnswer((_) async {});

        await authService.clearPin();

        verify(() => mockStorage.delete(key: 'app_lock_pin')).called(1);
      });
    });
  });
}
