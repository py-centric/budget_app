import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../../domain/entities/app_lock_settings.dart';
import '../../domain/services/auth_service.dart';

class AuthServiceImpl implements AuthService {
  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  static const String _pinKey = 'app_lock_pin';

  AuthServiceImpl({
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuth,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _localAuth = localAuth ?? LocalAuthentication();

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Budget App',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final storedPin = await _secureStorage.read(key: _pinKey);
    return storedPin == pin;
  }

  @override
  Future<void> savePin(String pin) async {
    await _secureStorage.write(key: _pinKey, value: pin);
  }

  @override
  Future<bool> hasPin() async {
    final pin = await _secureStorage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  @override
  Future<void> clearPin() async {
    await _secureStorage.delete(key: _pinKey);
  }
}

class AppLockRepository {
  final AuthService _authService;

  AppLockRepository({required AuthService authService})
    : _authService = authService;

  Future<AppLockSettings> getSettings() async {
    final isBiometricAvailable = await _authService.isBiometricAvailable();
    final hasPin = await _authService.hasPin();

    return AppLockSettings(
      isEnabled: hasPin || isBiometricAvailable,
      authMethod: isBiometricAvailable ? AuthMethod.biometrics : AuthMethod.pin,
    );
  }

  Future<void> enableLock(AuthMethod method, {String? pin}) async {
    if (method == AuthMethod.pin && pin != null) {
      await _authService.savePin(pin);
    }
  }

  Future<void> disableLock() async {
    await _authService.clearPin();
  }

  Future<bool> verifyAuth(String? pin) async {
    if (pin != null) {
      return await _authService.verifyPin(pin);
    }
    return await _authService.authenticateWithBiometrics();
  }

  Future<bool> isBiometricAvailable() async {
    return await _authService.isBiometricAvailable();
  }
}
