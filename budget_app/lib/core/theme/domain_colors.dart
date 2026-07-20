import 'package:flutter/material.dart';

class DomainColors extends ThemeExtension<DomainColors> {
  final Color incomeColor;
  final Color expenseColor;

  const DomainColors({
    required this.incomeColor,
    required this.expenseColor,
  });

  @override
  DomainColors copyWith({Color? incomeColor, Color? expenseColor}) {
    return DomainColors(
      incomeColor: incomeColor ?? this.incomeColor,
      expenseColor: expenseColor ?? this.expenseColor,
    );
  }

  @override
  DomainColors lerp(DomainColors? other, double t) {
    if (other is! DomainColors) return this;
    return DomainColors(
      incomeColor: Color.lerp(incomeColor, other.incomeColor, t)!,
      expenseColor: Color.lerp(expenseColor, other.expenseColor, t)!,
    );
  }

  static const defaultDomainColors = DomainColors(
    incomeColor: Color(0xFF4CAF50),
    expenseColor: Color(0xFFF44336),
  );
}
