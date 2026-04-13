import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  bool _showPinInput = false;
  bool _hasAttemptedBiometric = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Delay biometrics attempt slightly to ensure bloc is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometric();
    });
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
    // Only try biometrics once per page load
    if (_hasAttemptedBiometric) return;
    _hasAttemptedBiometric = true;

    final state = context.read<AppLockBloc>().state;
    // Try biometrics if available - this will show the native biometric prompt
    if (state.isBiometricAvailable) {
      context.read<AppLockBloc>().add(AppLockAuthenticateWithBiometrics());
    }
  }

  void _switchToPin() {
    setState(() {
      _showPinInput = true;
    });
  }

  void _switchToBiometrics() {
    setState(() {
      _showPinInput = false;
    });
    _tryBiometric();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppLockBloc, AppLockState>(
      listener: (context, state) {
        if (state.status == AppLockStatus.authenticated) {
          widget.onUnlocked();
        } else if (state.status == AppLockStatus.error &&
            state.errorMessage != null) {
          // If biometrics fails, show PIN option
          if (state.errorMessage?.contains('Biometric') ?? false) {
            setState(() {
              _showPinInput = true;
            });
          }
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
                        _showPinInput
                            ? 'Enter your PIN to unlock'
                            : 'Use biometrics or PIN to unlock',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Show PIN input by default, or if biometrics failed
                      if (_showPinInput || !state.isBiometricAvailable)
                        _buildPinInput()
                      else
                        BiometricButtonWidget(
                          onPressed: _tryBiometric,
                          isAvailable: state.isBiometricAvailable,
                        ),
                      // Show toggle between PIN and biometrics if biometrics available
                      if (state.isBiometricAvailable) ...[
                        const SizedBox(height: 16),
                        if (_showPinInput)
                          TextButton.icon(
                            onPressed: _switchToBiometrics,
                            icon: const Icon(Icons.fingerprint),
                            label: const Text('Use Biometrics'),
                          )
                        else
                          TextButton.icon(
                            onPressed: _switchToPin,
                            icon: const Icon(Icons.pin),
                            label: const Text('Use PIN instead'),
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
