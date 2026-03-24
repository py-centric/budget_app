import 'package:equatable/equatable.dart';
import '../../domain/entities/app_lock_settings.dart';

abstract class AppLockEvent extends Equatable {
  const AppLockEvent();

  @override
  List<Object?> get props => [];
}

class AppLockLoadSettings extends AppLockEvent {}

class AppLockEnable extends AppLockEvent {
  final AuthMethod method;
  final String? pin;

  const AppLockEnable({required this.method, this.pin});

  @override
  List<Object?> get props => [method, pin];
}

class AppLockDisable extends AppLockEvent {
  final String? pin;

  const AppLockDisable({this.pin});

  @override
  List<Object?> get props => [pin];
}

class AppLockAuthenticate extends AppLockEvent {
  final String? pin;

  const AppLockAuthenticate({this.pin});

  @override
  List<Object?> get props => [pin];
}

class AppLockAuthenticateWithBiometrics extends AppLockEvent {}

class AppLockCheckBiometricAvailability extends AppLockEvent {}

class AppLockAppResumed extends AppLockEvent {}

class AppLockAppPaused extends AppLockEvent {}

class AppLockResetPin extends AppLockEvent {
  final String newPin;

  const AppLockResetPin({required this.newPin});

  @override
  List<Object?> get props => [newPin];
}
