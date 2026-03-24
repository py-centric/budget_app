import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/app_lock_settings.dart';
import '../bloc/app_lock_bloc.dart';
import '../bloc/app_lock_event.dart';
import '../bloc/app_lock_state.dart';
import '../widgets/pin_input_widget.dart';
import '../widgets/biometric_button_widget.dart';

class LockScreenPage extends StatefulWidget {
  final VoidCallback onUnlocked;

  const LockScreenPage({super.key, required this.onUnlocked});

  @override
  State<LockScreenPage> createState() => _LockScreenPageState();
}

class _LockScreenPageState extends State<LockScreenPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tryBiometric();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      context.read<AppLockBloc>().add(AppLockAppPaused());
    } else if (state == AppLifecycleState.resumed) {
      context.read<AppLockBloc>().add(AppLockAppResumed());
    }
  }

  void _tryBiometric() {
    final state = context.read<AppLockBloc>().state;
    if (state.settings.authMethod == AuthMethod.biometrics) {
      context.read<AppLockBloc>().add(AppLockAuthenticateWithBiometrics());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppLockBloc, AppLockState>(
      listener: (context, state) {
        if (state.status == AppLockStatus.authenticated) {
          widget.onUnlocked();
        } else if (state.status == AppLockStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: BlocBuilder<AppLockBloc, AppLockState>(
                builder: (context, state) {
                  if (state.status == AppLockStatus.lockedOut) {
                    return _buildLockoutMessage(state);
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Budget App is Locked',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.settings.authMethod == AuthMethod.biometrics
                            ? 'Use biometrics to unlock'
                            : 'Enter PIN to unlock',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (state.settings.authMethod == AuthMethod.pin)
                        _buildPinInput()
                      else
                        BiometricButtonWidget(
                          onPressed: _tryBiometric,
                          isAvailable: state.isBiometricAvailable,
                        ),
                      if (state.settings.authMethod == AuthMethod.biometrics &&
                          state.isBiometricAvailable) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            context.read<AppLockBloc>().add(
                              const AppLockAuthenticate(),
                            );
                          },
                          child: const Text('Use PIN instead'),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinInput() {
    return PinInputWidget(
      pinLength: 6,
      onPinComplete: (pin) {
        context.read<AppLockBloc>().add(AppLockAuthenticate(pin: pin));
      },
    );
  }

  Widget _buildLockoutMessage(AppLockState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_clock,
          size: 64,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 24),
        Text(
          'Too Many Attempts',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Please wait ${state.lockoutRemaining?.inSeconds ?? 30} seconds',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
