import 'package:flutter/material.dart';
import '../../domain/entities/app_lock_settings.dart';
import '../widgets/pin_input_widget.dart';

class LockSetupDialog extends StatefulWidget {
  final bool isBiometricAvailable;
  final void Function(AuthMethod method, String? pin) onComplete;

  const LockSetupDialog({
    super.key,
    required this.isBiometricAvailable,
    required this.onComplete,
  });

  @override
  State<LockSetupDialog> createState() => _LockSetupDialogState();
}

class _LockSetupDialogState extends State<LockSetupDialog> {
  AuthMethod? _selectedMethod;
  String? _firstPin;
  bool _isConfirming = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isConfirming ? 'Confirm PIN' : 'Set Up App Lock'),
      content: SizedBox(
        width: double.maxFinite,
        child: _selectedMethod == null
            ? _buildMethodSelection()
            : _buildPinInput(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_selectedMethod != null && _firstPin != null) {
              // Go back to method selection if user wants to change
              setState(() {
                _selectedMethod = null;
                _firstPin = null;
                _isConfirming = false;
                _errorMessage = null;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Text(_selectedMethod == null ? 'Cancel' : 'Back'),
        ),
      ],
    );
  }

  Widget _buildMethodSelection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Choose authentication method:'),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.pin),
          title: const Text('PIN'),
          subtitle: const Text('6-digit code'),
          onTap: () {
            setState(() {
              _selectedMethod = AuthMethod.pin;
            });
          },
        ),
        if (widget.isBiometricAvailable)
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Biometrics'),
            subtitle: const Text('Fingerprint or Face ID'),
            onTap: () {
              widget.onComplete(AuthMethod.biometrics, null);
              Navigator.of(context).pop();
            },
          ),
      ],
    );
  }

  Widget _buildPinInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _isConfirming ? 'Enter PIN again to confirm' : 'Enter a 6-digit PIN',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        PinInputWidget(
          key: ValueKey(_isConfirming), // Reset widget when toggling confirm
          pinLength: 6,
          onPinComplete: (pin) {
            if (!_isConfirming) {
              setState(() {
                _firstPin = pin;
                _isConfirming = true;
                _errorMessage = null;
              });
            } else {
              if (pin == _firstPin) {
                widget.onComplete(AuthMethod.pin, pin);
                Navigator.of(context).pop();
              } else {
                setState(() {
                  _errorMessage = 'PINs do not match. Try again.';
                  _firstPin = null;
                  _isConfirming = false;
                });
              }
            }
          },
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }
}
