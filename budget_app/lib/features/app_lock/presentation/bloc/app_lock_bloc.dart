import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/app_lock_repository_impl.dart';
import '../../domain/entities/app_lock_settings.dart';
import 'app_lock_event.dart';
import 'app_lock_state.dart';

class AppLockBloc extends Bloc<AppLockEvent, AppLockState> {
  final AppLockRepository _repository;
  static const int maxFailedAttempts = 5;
  static const Duration lockoutDuration = Duration(seconds: 30);
  static const Duration backgroundTimeout = Duration(minutes: 5);

  AppLockBloc({required AppLockRepository repository})
    : _repository = repository,
      super(const AppLockState()) {
    on<AppLockLoadSettings>(_onLoadSettings);
    on<AppLockEnable>(_onEnable);
    on<AppLockDisable>(_onDisable);
    on<AppLockAuthenticate>(_onAuthenticate);
    on<AppLockAuthenticateWithBiometrics>(_onAuthenticateWithBiometrics);
    on<AppLockCheckBiometricAvailability>(_onCheckBiometricAvailability);
    on<AppLockAppResumed>(_onAppResumed);
    on<AppLockAppPaused>(_onAppPaused);
    on<AppLockResetPin>(_onResetPin);
  }

  Future<void> _onLoadSettings(
    AppLockLoadSettings event,
    Emitter<AppLockState> emit,
  ) async {
    emit(state.copyWith(status: AppLockStatus.loading));
    try {
      final settings = await _repository.getSettings();
      final isBiometricAvailable = await _repository.isBiometricAvailable();

      if (settings.isEnabled) {
        emit(
          state.copyWith(
            status: AppLockStatus.locked,
            settings: settings,
            isBiometricAvailable: isBiometricAvailable,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AppLockStatus.loaded,
            settings: settings,
            isBiometricAvailable: isBiometricAvailable,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AppLockStatus.error,
          errorMessage: 'Failed to load settings',
        ),
      );
    }
  }

  Future<void> _onEnable(
    AppLockEnable event,
    Emitter<AppLockState> emit,
  ) async {
    try {
      await _repository.enableLock(event.method, pin: event.pin);
      final settings = state.settings.copyWith(
        isEnabled: true,
        authMethod: event.method,
      );
      emit(state.copyWith(status: AppLockStatus.locked, settings: settings));
    } catch (e) {
      emit(
        state.copyWith(
          status: AppLockStatus.error,
          errorMessage: 'Failed to enable lock',
        ),
      );
    }
  }

  Future<void> _onDisable(
    AppLockDisable event,
    Emitter<AppLockState> emit,
  ) async {
    try {
      final isValid = await _repository.verifyAuth(event.pin);
      if (!isValid) {
        emit(
          state.copyWith(
            status: AppLockStatus.error,
            errorMessage: 'Invalid PIN',
            failedAttempts: state.failedAttempts + 1,
          ),
        );
        return;
      }

      await _repository.disableLock();
      final settings = state.settings.copyWith(isEnabled: false);
      emit(
        state.copyWith(
          status: AppLockStatus.loaded,
          settings: settings,
          failedAttempts: 0,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AppLockStatus.error,
          errorMessage: 'Failed to disable lock',
        ),
      );
    }
  }

  Future<void> _onAuthenticate(
    AppLockAuthenticate event,
    Emitter<AppLockState> emit,
  ) async {
    if (state.isLockedOut) {
      emit(
        state.copyWith(
          status: AppLockStatus.lockedOut,
          errorMessage: 'Too many attempts. Try again later.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AppLockStatus.authenticating));

    try {
      final isValid = await _repository.verifyAuth(event.pin);
      if (isValid) {
        emit(
          state.copyWith(
            status: AppLockStatus.authenticated,
            failedAttempts: 0,
          ),
        );
      } else {
        final newFailedAttempts = state.failedAttempts + 1;
        if (newFailedAttempts >= maxFailedAttempts) {
          emit(
            state.copyWith(
              status: AppLockStatus.lockedOut,
              failedAttempts: newFailedAttempts,
              lockoutUntil: DateTime.now().add(lockoutDuration),
              errorMessage: 'Too many failed attempts. Locked for 30 seconds.',
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: AppLockStatus.error,
              failedAttempts: newFailedAttempts,
              errorMessage:
                  'Invalid PIN. ${maxFailedAttempts - newFailedAttempts} attempts remaining.',
            ),
          );
        }
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AppLockStatus.error,
          errorMessage: 'Authentication failed',
        ),
      );
    }
  }

  Future<void> _onAuthenticateWithBiometrics(
    AppLockAuthenticateWithBiometrics event,
    Emitter<AppLockState> emit,
  ) async {
    if (state.isLockedOut) {
      emit(
        state.copyWith(
          status: AppLockStatus.lockedOut,
          errorMessage: 'Too many attempts. Try again later.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AppLockStatus.authenticating));

    try {
      final isValid = await _repository.verifyAuth(null);
      if (isValid) {
        emit(
          state.copyWith(
            status: AppLockStatus.authenticated,
            failedAttempts: 0,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AppLockStatus.error,
            errorMessage: 'Biometric authentication failed',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AppLockStatus.error,
          errorMessage: 'Biometric authentication failed',
        ),
      );
    }
  }

  Future<void> _onCheckBiometricAvailability(
    AppLockCheckBiometricAvailability event,
    Emitter<AppLockState> emit,
  ) async {
    final isAvailable = await _repository.isBiometricAvailable();
    emit(state.copyWith(isBiometricAvailable: isAvailable));
  }

  Future<void> _onAppPaused(
    AppLockAppPaused event,
    Emitter<AppLockState> emit,
  ) async {
    if (state.status == AppLockStatus.authenticated) {
      final settings = state.settings.copyWith(
        lastBackgroundTime: DateTime.now(),
      );
      emit(state.copyWith(status: AppLockStatus.locked, settings: settings));
    }
  }

  Future<void> _onAppResumed(
    AppLockAppResumed event,
    Emitter<AppLockState> emit,
  ) async {
    if (!state.settings.isEnabled) return;

    final lastBackground = state.settings.lastBackgroundTime;
    if (lastBackground != null) {
      final elapsed = DateTime.now().difference(lastBackground);
      if (elapsed >= backgroundTimeout) {
        emit(state.copyWith(status: AppLockStatus.locked));
      }
    } else {
      emit(state.copyWith(status: AppLockStatus.locked));
    }
  }

  Future<void> _onResetPin(
    AppLockResetPin event,
    Emitter<AppLockState> emit,
  ) async {
    try {
      await _repository.enableLock(AuthMethod.pin, pin: event.newPin);
      emit(state.copyWith(status: AppLockStatus.loaded, errorMessage: null));
    } catch (e) {
      emit(
        state.copyWith(
          status: AppLockStatus.error,
          errorMessage: 'Failed to reset PIN',
        ),
      );
    }
  }
}
