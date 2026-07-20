import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/tags/domain/entities/tag.dart';

void main() {
  group('Tag', () {
    final now = DateTime(2024, 6, 15);
    final tag = Tag(
      id: 't-1',
      name: 'Essential',
      color: '#FF0000',
      createdAt: now,
    );

    test('props are correct', () {
      expect(tag.props, ['t-1', 'Essential', '#FF0000', now]);
    });

    test('copyWith creates new instance', () {
      final updated = tag.copyWith(name: 'Important');
      expect(updated.name, 'Important');
      expect(updated.id, 't-1');
      expect(updated, isNot(equals(tag)));
    });

    test('copyWith with no args returns equal instance', () {
      expect(tag.copyWith(), equals(tag));
    });

    test('equality works', () {
      final tag2 = Tag(
        id: 't-1', name: 'Essential', color: '#FF0000', createdAt: now,
      );
      expect(tag, equals(tag2));
    });

    test('toMap serializes correctly', () {
      final map = tag.toMap();
      expect(map['id'], 't-1');
      expect(map['name'], 'Essential');
      expect(map['color'], '#FF0000');
      expect(map['created_at'], now.toIso8601String());
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'id': 't-1', 'name': 'Essential', 'color': '#FF0000',
        'created_at': now.toIso8601String(),
      };
      final result = Tag.fromMap(map);
      expect(result.id, 't-1');
      expect(result.name, 'Essential');
      expect(result.color, '#FF0000');
    });

    test('fromMap with null color', () {
      final map = {
        'id': 't-1', 'name': 'Essential', 'color': null,
        'created_at': now.toIso8601String(),
      };
      final result = Tag.fromMap(map);
      expect(result.color, isNull);
    });
  });
}
