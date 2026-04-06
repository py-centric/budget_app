import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/utils/chart_color_utils.dart';

void main() {
  group('ChartColorUtils', () {
    group('calculateSharpStops', () {
      test('should return full range when maxY <= minY', () {
        final result = ChartColorUtils.calculateSharpStops(
          minY: 100.0,
          maxY: 100.0,
        );

        expect(result, [0.0, 1.0]);
      });

      test('should return full range when all values above threshold', () {
        final result = ChartColorUtils.calculateSharpStops(
          minY: 10.0,
          maxY: 100.0,
          threshold: 5.0,
        );

        expect(result, [0.0, 1.0]);
      });

      test('should return full range when all values below threshold', () {
        final result = ChartColorUtils.calculateSharpStops(
          minY: -100.0,
          maxY: -10.0,
          threshold: 0.0,
        );

        expect(result, [0.0, 1.0]);
      });

      test('should calculate correct stop when values span threshold', () {
        final result = ChartColorUtils.calculateSharpStops(
          minY: -100.0,
          maxY: 100.0,
          threshold: 0.0,
        );

        expect(result.length, 4);
        expect(result[0], 0.0);
        expect(result[1], 0.5);
        expect(result[2], 0.5);
        expect(result[3], 1.0);
      });

      test('should handle custom threshold', () {
        final result = ChartColorUtils.calculateSharpStops(
          minY: 0.0,
          maxY: 100.0,
          threshold: 25.0,
        );

        expect(result[1], 0.25);
        expect(result[2], 0.25);
      });
    });

    group('getSharpGradientColors', () {
      test('should return positive colors when all above threshold', () {
        final result = ChartColorUtils.getSharpGradientColors(
          positiveColor: Colors.green,
          negativeColor: Colors.red,
          minY: 10.0,
          maxY: 100.0,
          threshold: 5.0,
        );

        expect(result, [Colors.green, Colors.green]);
      });

      test('should return negative colors when all below threshold', () {
        final result = ChartColorUtils.getSharpGradientColors(
          positiveColor: Colors.green,
          negativeColor: Colors.red,
          minY: -100.0,
          maxY: -10.0,
          threshold: 0.0,
        );

        expect(result, [Colors.red, Colors.red]);
      });

      test('should return mixed colors when spanning threshold', () {
        final result = ChartColorUtils.getSharpGradientColors(
          positiveColor: Colors.green,
          negativeColor: Colors.red,
          minY: -100.0,
          maxY: 100.0,
          threshold: 0.0,
        );

        expect(result.length, 4);
        expect(result[0], Colors.red);
        expect(result[1], Colors.red);
        expect(result[2], Colors.green);
        expect(result[3], Colors.green);
      });
    });
  });
}
