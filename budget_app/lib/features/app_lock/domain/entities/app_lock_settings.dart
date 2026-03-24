import 'package:equatable/equatable.dart';

enum AuthMethod { pin, biometrics }

class AppLockSettings extends Equatable {
  final bool isEnabled;
  final AuthMethod authMethod;
  final DateTime? lastBackgroundTime;

  const AppLockSettings({
    this.isEnabled = false,
    this.authMethod = AuthMethod.pin,
    this.lastBackgroundTime,
  });

  AppLockSettings copyWith({
    bool? isEnabled,
    AuthMethod? authMethod,
    DateTime? lastBackgroundTime,
  }) {
    return AppLockSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      authMethod: authMethod ?? this.authMethod,
      lastBackgroundTime: lastBackgroundTime ?? this.lastBackgroundTime,
    );
  }

  @override
  List<Object?> get props => [isEnabled, authMethod, lastBackgroundTime];
}
