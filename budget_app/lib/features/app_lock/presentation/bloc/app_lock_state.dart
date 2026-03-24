import 'package:equatable/equatable.dart';
import '../../domain/entities/app_lock_settings.dart';

enum AppLockStatus {
  initial,
  loading,
  loaded,
  authenticating,
  authenticated,
  locked,
  error,
  lockedOut,
}

class AppLockState extends Equatable {
  final AppLockStatus status;
  final AppLockSettings settings;
  final bool isBiometricAvailable;
  final int failedAttempts;
  final DateTime? lockoutUntil;
  final String? errorMessage;

  const AppLockState({
    this.status = AppLockStatus.initial,
    this.settings = const AppLockSettings(),
    this.isBiometricAvailable = false,
    this.failedAttempts = 0,
    this.lockoutUntil,
    this.errorMessage,
  });

  AppLockState copyWith({
    AppLockStatus? status,
    AppLockSettings? settings,
    bool? isBiometricAvailable,
    int? failedAttempts,
    DateTime? lockoutUntil,
    String? errorMessage,
  }) {
    return AppLockState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockoutUntil: lockoutUntil ?? this.lockoutUntil,
      errorMessage: errorMessage,
    );
  }

  bool get isLockedOut {
    if (lockoutUntil == null) return false;
    return DateTime.now().isBefore(lockoutUntil!);
  }

  Duration? get lockoutRemaining {
    if (lockoutUntil == null) return null;
    final remaining = lockoutUntil!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  @override
  List<Object?> get props => [
    status,
    settings,
    isBiometricAvailable,
    failedAttempts,
    lockoutUntil,
    errorMessage,
  ];
}
