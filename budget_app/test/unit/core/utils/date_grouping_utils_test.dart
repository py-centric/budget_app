import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/core/utils/date_grouping_utils.dart';

void main() {
  group('DateGroupingUtils', () {
    test(
      'getWeekEndingDate should return correct end date for Monday start',
      () {
        final date = DateTime(2024, 1, 10); // Wednesday
        final result = DateGroupingUtils.getWeekEndingDate(
          date,
          DateTime.monday,
        );

        expect(result.weekday, DateTime.sunday);
        expect(result.day, 14);
      },
    );

    test(
      'getWeekEndingDate should return same day when already Sunday for Monday start',
      () {
        final date = DateTime(2024, 1, 14); // Sunday
        final result = DateGroupingUtils.getWeekEndingDate(
          date,
          DateTime.monday,
        );

        expect(result.weekday, DateTime.sunday);
        expect(result.day, 14);
      },
    );

    test('getWeekEndingDate should handle Sunday start', () {
      final date = DateTime(2024, 1, 10); // Wednesday
      final result = DateGroupingUtils.getWeekEndingDate(date, DateTime.sunday);

      expect(result.weekday, DateTime.saturday);
      expect(result.day, 13);
    });

    test('getWeekEndingDate should handle Friday start', () {
      final date = DateTime(2024, 1, 10); // Wednesday
      final result = DateGroupingUtils.getWeekEndingDate(date, DateTime.friday);

      expect(result.weekday, DateTime.thursday);
      expect(result.day, 11);
    });

    test('getWeekEndingDate should reset time to midnight', () {
      final date = DateTime(2024, 1, 10, 14, 30, 45);
      final result = DateGroupingUtils.getWeekEndingDate(date, DateTime.monday);

      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
    });
  });
}
