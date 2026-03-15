import 'package:flutter/material.dart';

class ChartColorUtils {
  /// Calculates gradient stops for a sharp transition at [threshold].
  /// Assumes the gradient maps from [minY] (0.0) to [maxY] (1.0).
  static List<double> calculateSharpStops({
    required double minY,
    required double maxY,
    double threshold = 0.0,
  }) {
    if (maxY <= minY) return [0.0, 1.0];
    
    // If all values are above threshold
    if (minY >= threshold) return [0.0, 1.0];
    
    // If all values are below threshold
    if (maxY <= threshold) return [0.0, 1.0];

    final stop = (threshold - minY) / (maxY - minY);
    
    // Ensure stop is within bounds and provides a sharp transition
    final safeStop = stop.clamp(0.0, 1.0);
    
    return [0.0, safeStop, safeStop, 1.0];
  }

  /// Returns colors for the gradient based on the threshold transition.
  static List<Color> getSharpGradientColors({
    required Color positiveColor,
    required Color negativeColor,
    required double minY,
    required double maxY,
    double threshold = 0.0,
  }) {
    if (minY >= threshold) return [positiveColor, positiveColor];
    if (maxY <= threshold) return [negativeColor, negativeColor];
    
    return [negativeColor, negativeColor, positiveColor, positiveColor];
  }
}
