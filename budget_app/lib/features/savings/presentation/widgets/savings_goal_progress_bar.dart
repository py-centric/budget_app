import 'package:flutter/material.dart';

class SavingsGoalProgressBar extends StatelessWidget {
  final double currentAmount;
  final double targetAmount;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;

  const SavingsGoalProgressBar({
    super.key,
    required this.currentAmount,
    required this.targetAmount,
    this.progressColor,
    this.backgroundColor,
    this.height = 12.0,
  });

  double get _progressPercentage {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final color = progressColor ?? Colors.blue;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[200],
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progressPercentage,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.8), color],
                ),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
          if (_progressPercentage >= 1.0)
            Positioned.fill(
              child: Center(
                child: Icon(Icons.check, size: height - 2, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
