import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:budget_app/core/theme/app_spacing.dart';

class ColorPickerField extends StatefulWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;
  final String label;

  const ColorPickerField({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    required this.label,
  });

  @override
  State<ColorPickerField> createState() => _ColorPickerFieldState();
}

class _ColorPickerFieldState extends State<ColorPickerField> {
  late TextEditingController _hexController;
  String? _errorText;

  static const double _circleSize = 28;
  static const double _tapTargetSize = 48;

  static const List<Color> presetColors = [
    Color(0xFFF44336), // Red
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF03A9F4), // Light Blue
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFF8BC34A), // Light Green
    Color(0xFFCDDC39), // Lime
    Color(0xFFFFEB3B), // Yellow
    Color(0xFFFFC107), // Amber
    Color(0xFFFF9800), // Orange
    Color(0xFFFF5722), // Deep Orange
  ];

  @override
  void initState() {
    super.initState();
    _hexController = TextEditingController(
      text: _colorToHex(widget.selectedColor),
    );
  }

  @override
  void didUpdateWidget(ColorPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedColor != widget.selectedColor) {
      _hexController.text = _colorToHex(widget.selectedColor);
      _errorText = null;
    }
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return color.toARGB32().toRadixString(16).substring(2).toUpperCase();
  }

  Color? _hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length != 6) return null;
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return null;
    return Color(value | 0xFF000000);
  }

  void _onHexChanged(String value) {
    final color = _hexToColor(value);
    if (color != null) {
      setState(() => _errorText = null);
      widget.onColorSelected(color);
    } else if (value.isNotEmpty) {
      setState(() => _errorText = 'Invalid hex');
    }
  }

  void _selectColor(Color color) {
    _hexController.text = _colorToHex(color);
    setState(() => _errorText = null);
    widget.onColorSelected(color);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: presetColors.map((color) {
            final isSelected = color.toARGB32() == widget.selectedColor.toARGB32();
            return _buildColorItem(color, isSelected, colorScheme);
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.selectedColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: _hexController,
                decoration: InputDecoration(
                  labelText: 'Hex Color',
                  hintText: 'FF5722',
                  prefixText: '# ',
                  errorText: _errorText,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: _onHexChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorItem(Color color, bool isSelected, ColorScheme colorScheme) {
    return SizedBox(
      width: _tapTargetSize,
      height: _tapTargetSize,
      child: InkResponse(
        onTap: () => _selectColor(color),
        customBorder: const CircleBorder(),
        radius: _tapTargetSize / 2,
        splashColor: color.withValues(alpha: 0.3),
        highlightColor: color.withValues(alpha: 0.15),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            width: isSelected ? _circleSize + 6 : _circleSize,
            height: isSelected ? _circleSize + 6 : _circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? null : color,
              border: isSelected
                  ? Border.all(color: colorScheme.primary, width: 3)
                  : null,
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: _circleSize,
                      height: _circleSize,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
