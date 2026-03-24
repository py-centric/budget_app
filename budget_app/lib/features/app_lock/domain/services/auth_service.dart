abstract class AuthService {
  Future<bool> isBiometricAvailable();
  Future<bool> authenticateWithBiometrics();
  Future<bool> verifyPin(String pin);
  Future<void> savePin(String pin);
  Future<bool> hasPin();
  Future<void> clearPin();
}
