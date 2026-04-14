import 'package:flutter/material.dart';

class CategoryLimitProgressBar extends StatelessWidget {
  final double spentAmount;
  final double limitAmount;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;

  const CategoryLimitProgressBar({
    super.key,
    required this.spentAmount,
    required this.limitAmount,
    this.progressColor,
    this.backgroundColor,
    this.height = 8.0,
  });

  double get _progressPercentage {
    if (limitAmount == 0) return 0;
    return (spentAmount / limitAmount).clamp(0.0, 1.0);
  }

  bool get _isOverBudget => spentAmount > limitAmount;

  Color get _effectiveProgressColor {
    if (_isOverBudget) {
      return progressColor ?? Colors.red;
    }
    if (_progressPercentage > 0.8) {
      return progressColor ?? Colors.orange;
    }
    return progressColor ?? Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[200],
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: _progressPercentage,
        child: Container(
          decoration: BoxDecoration(
            color: _effectiveProgressColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
