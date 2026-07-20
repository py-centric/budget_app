import 'package:flutter/material.dart';
import 'accessibility_settings.dart';

class AccessibilityProvider extends InheritedWidget {
  final AccessibilitySettings settings;
  final ValueChanged<AccessibilitySettings> onSettingsChanged;

  const AccessibilityProvider({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    required super.child,
  });

  static AccessibilitySettings of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AccessibilityProvider>();
    return provider?.settings ?? const AccessibilitySettings();
  }

  static void update(BuildContext context, AccessibilitySettings newSettings) {
    final provider = context.dependOnInheritedWidgetOfExactType<AccessibilityProvider>();
    provider?.onSettingsChanged(newSettings);
  }

  @override
  bool updateShouldNotify(AccessibilityProvider oldWidget) {
    return settings != oldWidget.settings;
  }
}
