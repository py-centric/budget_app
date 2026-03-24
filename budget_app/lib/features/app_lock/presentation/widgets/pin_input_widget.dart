import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinInputWidget extends StatefulWidget {
  final int pinLength;
  final void Function(String) onPinComplete;
  final void Function()? onPinChanged;

  const PinInputWidget({
    super.key,
    this.pinLength = 4,
    required this.onPinComplete,
    this.onPinChanged,
  });

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  String _pin = '';

  void _onKeyPressed(String key) {
    HapticFeedback.lightImpact();

    if (key == 'delete') {
      if (_pin.isNotEmpty) {
        setState(() {
          _pin = _pin.substring(0, _pin.length - 1);
        });
        widget.onPinChanged?.call();
      }
    } else if (_pin.length < widget.pinLength) {
      setState(() {
        _pin += key;
      });
      widget.onPinChanged?.call();

      if (_pin.length == widget.pinLength) {
        widget.onPinComplete(_pin);
      }
    }
  }

  void clear() {
    setState(() {
      _pin = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.pinLength,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < _pin.length
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildKeypad(context),
      ],
    );
  }

  Widget _buildKeypad(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKey(context, '1'),
            _buildKey(context, '2'),
            _buildKey(context, '3'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKey(context, '4'),
            _buildKey(context, '5'),
            _buildKey(context, '6'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKey(context, '7'),
            _buildKey(context, '8'),
            _buildKey(context, '9'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 80, height: 80),
            _buildKey(context, '0'),
            _buildKey(context, 'delete', isIcon: true),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(BuildContext context, String key, {bool isIcon = false}) {
    return SizedBox(
      width: 80,
      height: 80,
      child: TextButton(
        onPressed: () => _onKeyPressed(key),
        style: TextButton.styleFrom(shape: const CircleBorder()),
        child: isIcon
            ? Icon(
                Icons.backspace_outlined,
                size: 28,
                color: Theme.of(context).colorScheme.onSurface,
              )
            : Text(
                key,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
      ),
    );
  }
}
