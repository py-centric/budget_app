import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/utils/date_utils.dart';

void main() {
  group('DateUtilsHelper', () {
    test('shiftDateToPeriod should shift to same month and year', () {
      final original = DateTime(2024, 3, 15, 10, 30);
      final result = DateUtilsHelper.shiftDateToPeriod(original, 2024, 3);

      expect(result.year, 2024);
      expect(result.month, 3);
      expect(result.day, 15);
      expect(result.hour, 10);
      expect(result.minute, 30);
    });

    test('shiftDateToPeriod should shift to different month and year', () {
      final original = DateTime(2024, 1, 15);
      final result = DateUtilsHelper.shiftDateToPeriod(original, 2024, 6);

      expect(result.year, 2024);
      expect(result.month, 6);
      expect(result.day, 15);
    });

    test('shiftDateToPeriod should clamp day for short months', () {
      final original = DateTime(2024, 1, 31);
      final result = DateUtilsHelper.shiftDateToPeriod(original, 2024, 2);

      expect(result.year, 2024);
      expect(result.month, 2);
      expect(result.day, 29); // 2024 is a leap year
    });

    test('shiftDateToPeriod should clamp day for non-leap year February', () {
      final original = DateTime(2023, 1, 31);
      final result = DateUtilsHelper.shiftDateToPeriod(original, 2023, 2);

      expect(result.year, 2023);
      expect(result.month, 2);
      expect(result.day, 28); // 2023 is not a leap year
    });

    test('shiftDateToPeriod should handle day within month range', () {
      final original = DateTime(2024, 5, 10);
      final result = DateUtilsHelper.shiftDateToPeriod(original, 2024, 6);

      expect(result.day, 10);
    });

    test('shiftDateToPeriod should preserve time components', () {
      final original = DateTime(2024, 1, 15, 14, 25, 30, 500);
      final result = DateUtilsHelper.shiftDateToPeriod(original, 2024, 12);

      expect(result.hour, 14);
      expect(result.minute, 25);
      expect(result.second, 30);
      expect(result.millisecond, 500);
    });
  });
}
