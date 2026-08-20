import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/theme/app_theme.dart';
import 'package:budget_app/core/theme/domain_colors.dart';

double _relativeLuminance(Color color) {
  double channelLuminance(int channelValue) {
    final srgb = channelValue / 255.0;
    return srgb <= 0.04045
        ? srgb / 12.92
        : pow((srgb + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = channelLuminance((color.toARGB32() >> 16) & 0xFF);
  final g = channelLuminance((color.toARGB32() >> 8) & 0xFF);
  final b = channelLuminance(color.toARGB32() & 0xFF);

  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _contrastRatio(Color color1, Color color2) {
  final l1 = _relativeLuminance(color1);
  final l2 = _relativeLuminance(color2);
  final lighter = max(l1, l2);
  final darker = min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  const seedColor = Color(0xFF4CAF50);
  const domainColors = DomainColors(
    incomeColor: Color(0xFF4CAF50),
    expenseColor: Color(0xFFF44336),
  );

  group('AppTheme.highContrastTheme', () {
    test('builds high contrast dark theme with pure black surface and background', () {
      final theme = AppTheme.highContrastTheme(seedColor, domainColors);

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF000000));
      expect(theme.colorScheme.surface, const Color(0xFF000000));
    });

    test('satisfies WCAG 2.1 AAA contrast ratios for primary elements against pure black', () {
      final theme = AppTheme.highContrastTheme(seedColor, domainColors);
      const black = Color(0xFF000000);

      // Text (White on Black) >= 7.0:1 (AAA)
      final textRatio = _contrastRatio(theme.colorScheme.onSurface, black);
      expect(textRatio, greaterThanOrEqualTo(20.0));

      // Primary Cyan on Black >= 7.0:1 (AAA)
      final primaryRatio = _contrastRatio(theme.colorScheme.primary, black);
      expect(primaryRatio, greaterThanOrEqualTo(15.0));

      // Secondary Yellow on Black >= 7.0:1 (AAA)
      final secondaryRatio = _contrastRatio(theme.colorScheme.secondary, black);
      expect(secondaryRatio, greaterThanOrEqualTo(18.0));

      // Primary text on primary container / button >= 7.0:1 (AAA)
      final onPrimaryRatio = _contrastRatio(theme.colorScheme.onPrimary, theme.colorScheme.primary);
      expect(onPrimaryRatio, greaterThanOrEqualTo(15.0));
    });

    test('satisfies WCAG 2.1 AA contrast ratios for error/expense elements', () {
      final theme = AppTheme.highContrastTheme(seedColor, domainColors);
      const black = Color(0xFF000000);

      // Error/Expense Red on Black >= 4.5:1 (AA)
      final errorRatio = _contrastRatio(theme.colorScheme.error, black);
      expect(errorRatio, greaterThanOrEqualTo(4.5));
    });

    test('provides accessible high contrast DomainColors', () {
      final theme = AppTheme.highContrastTheme(seedColor, domainColors);
      final domain = theme.extension<DomainColors>()!;
      const black = Color(0xFF000000);

      // Income color (Spring Green) on Black >= 7.0:1 (AAA)
      final incomeRatio = _contrastRatio(domain.incomeColor, black);
      expect(incomeRatio, greaterThanOrEqualTo(14.0));

      // Expense color on Black >= 4.5:1 (AA)
      final expenseRatio = _contrastRatio(domain.expenseColor, black);
      expect(expenseRatio, greaterThanOrEqualTo(4.5));
    });

    test('configures distinct high contrast outlines and borders across components', () {
      final theme = AppTheme.highContrastTheme(seedColor, domainColors);

      // Card border
      final cardBorder = (theme.cardTheme.shape as RoundedRectangleBorder).side;
      expect(cardBorder.color, const Color(0xFFFFFFFF));
      expect(cardBorder.width, greaterThanOrEqualTo(1.5));

      // Divider
      expect(theme.dividerTheme.color, const Color(0xFFFFFFFF));
      expect(theme.dividerTheme.thickness, greaterThanOrEqualTo(1.5));

      // Input decoration
      final border = theme.inputDecorationTheme.border as OutlineInputBorder;
      expect(border.borderSide.color, const Color(0xFFFFFFFF));
      expect(border.borderSide.width, greaterThanOrEqualTo(2.0));

      final focusedBorder = theme.inputDecorationTheme.focusedBorder as OutlineInputBorder;
      expect(focusedBorder.borderSide.color, const Color(0xFF00FFFF));
      expect(focusedBorder.borderSide.width, greaterThanOrEqualTo(2.5));

      // Dialog shape
      final dialogBorder = (theme.dialogTheme.shape as RoundedRectangleBorder).side;
      expect(dialogBorder.color, const Color(0xFFFFFFFF));
      expect(dialogBorder.width, greaterThanOrEqualTo(2.0));
    });
  });

  group('AppTheme other themes baseline', () {
    test('lightTheme has light brightness and DomainColors extension', () {
      final theme = AppTheme.lightTheme(seedColor, domainColors);
      expect(theme.brightness, Brightness.light);
      expect(theme.extension<DomainColors>(), isNotNull);
    });

    test('darkTheme has dark brightness and DomainColors extension', () {
      final theme = AppTheme.darkTheme(seedColor, domainColors);
      expect(theme.brightness, Brightness.dark);
      expect(theme.extension<DomainColors>(), isNotNull);
    });

    test('oledDarkTheme has pure black surface and DomainColors extension', () {
      final theme = AppTheme.oledDarkTheme(seedColor, domainColors);
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF000000));
      expect(theme.extension<DomainColors>(), isNotNull);
    });
  });
}
