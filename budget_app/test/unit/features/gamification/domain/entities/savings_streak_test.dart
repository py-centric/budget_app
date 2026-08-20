import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/gamification/domain/entities/savings_streak.dart';

void main() {
  group('SavingsStreak', () {
    test('props are correct', () {
      final now = DateTime(2024, 6, 15);
      final streak = SavingsStreak(
        currentStreak: 15,
        longestStreak: 30,
        lastSavingsDate: now,
      );
      expect(streak.currentStreak, 15);
      expect(streak.longestStreak, 30);
      expect(streak.lastSavingsDate, now);
    });

    test('copyWith creates new instance', () {
      final streak = SavingsStreak(
        currentStreak: 15, longestStreak: 30,
        lastSavingsDate: DateTime(2024, 6, 15),
      );
      final updated = streak.copyWith(currentStreak: 16);
      expect(updated.currentStreak, 16);
      expect(updated.longestStreak, 30);
      expect(updated, isNot(equals(streak)));
    });

    test('copyWith with no args returns equal instance', () {
      final streak = SavingsStreak(
        currentStreak: 15, longestStreak: 30,
        lastSavingsDate: DateTime(2024, 6, 15),
      );
      expect(streak.copyWith(), equals(streak));
    });

    test('default values', () {
      const defaultStreak = SavingsStreak();
      expect(defaultStreak.currentStreak, 0);
      expect(defaultStreak.longestStreak, 0);
      expect(defaultStreak.lastSavingsDate, isNull);
    });

    test('fromMap with null and missing fields uses defaults', () {
      final map = <String, dynamic>{
        'current_streak': 5,
        'longest_streak': 10,
      };
      final result = SavingsStreak.fromMap(map);
      expect(result.currentStreak, 5);
      expect(result.longestStreak, 10);
      expect(result.lastSavingsDate, isNull);
    });

    test('equality works', () {
      final s1 = SavingsStreak(
        currentStreak: 15, longestStreak: 30,
        lastSavingsDate: DateTime(2024, 6, 15),
      );
      final s2 = SavingsStreak(
        currentStreak: 15, longestStreak: 30,
        lastSavingsDate: DateTime(2024, 6, 15),
      );
      expect(s1, equals(s2));
    });

    test('inequality with different values', () {
      const s1 = SavingsStreak(currentStreak: 15, longestStreak: 30);
      const s2 = SavingsStreak(currentStreak: 20, longestStreak: 30);
      expect(s1, isNot(equals(s2)));
    });
  });
}
