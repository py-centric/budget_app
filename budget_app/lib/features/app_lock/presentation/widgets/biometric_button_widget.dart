import 'package:flutter/material.dart';

class BiometricButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isAvailable;

  const BiometricButtonWidget({
    super.key,
    required this.onPressed,
    this.isAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isAvailable) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              Icons.fingerprint,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Use Biometrics',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
