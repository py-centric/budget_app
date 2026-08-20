import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/gamification/domain/entities/achievement.dart';

void main() {
  group('Achievement', () {
    final now = DateTime(2024, 6, 15);
    final achievement = Achievement(
      id: 'ach-1',
      name: 'First Budget',
      description: 'Created your first budget',
      icon: '🎯',
      isUnlocked: true,
      unlockedAt: now,
    );

    test('props are correct', () {
      expect(achievement.props, [
        'ach-1', 'First Budget', 'Created your first budget',
        '🎯', true, now,
      ]);
    });

    test('copyWith creates new instance', () {
      final updated = achievement.copyWith(isUnlocked: false);
      expect(updated.isUnlocked, isFalse);
      expect(updated.name, 'First Budget');
      expect(updated, isNot(equals(achievement)));
    });

    test('copyWith with no args returns equal instance', () {
      expect(achievement.copyWith(), equals(achievement));
    });

    test('equality works', () {
      final achievement2 = Achievement(
        id: 'ach-1', name: 'First Budget', description: 'Created your first budget',
        icon: '🎯', isUnlocked: true, unlockedAt: now,
      );
      expect(achievement, equals(achievement2));
    });

    test('toMap serializes correctly', () {
      final map = achievement.toMap();
      expect(map['id'], 'ach-1');
      expect(map['name'], 'First Budget');
      expect(map['icon'], '🎯');
      expect(map['is_unlocked'], true);
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'id': 'ach-1', 'name': 'First Budget',
        'description': 'Created your first budget', 'icon': '🎯',
        'is_unlocked': true,
        'unlocked_at': now.toIso8601String(),
      };
      final result = Achievement.fromMap(map);
      expect(result.id, 'ach-1');
      expect(result.isUnlocked, isTrue);
      expect(result.unlockedAt, now);
    });

    test('fromMap with null unlockedAt', () {
      final map = {
        'id': 'ach-1', 'name': 'Locked', 'description': 'Not yet',
        'icon': '🔒', 'is_unlocked': false, 'unlocked_at': null,
      };
      final result = Achievement.fromMap(map);
      expect(result.isUnlocked, isFalse);
      expect(result.unlockedAt, isNull);
    });

    test('default isUnlocked is false', () {
      const locked = Achievement(
        id: 'ach-2', name: 'Locked', description: 'Not yet', icon: '🔒',
      );
      expect(locked.isUnlocked, isFalse);
      expect(locked.unlockedAt, isNull);
    });
  });
}
