import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/net_worth/domain/entities/net_worth_snapshot.dart';

void main() {
  group('NetWorthSnapshot', () {
    final now = DateTime(2024, 6, 15);
    final snapshot = NetWorthSnapshot(
      id: 'nw-1',
      date: DateTime(2024, 6, 1),
      totalAssets: 50000,
      totalLiabilities: 20000,
      netWorth: 30000,
    );

    test('props are correct', () {
      expect(snapshot.props, [
        'nw-1', DateTime(2024, 6, 1), 50000, 20000, 30000,
      ]);
    });

    test('equality works', () {
      final snapshot2 = NetWorthSnapshot(
        id: 'nw-1', date: DateTime(2024, 6, 1),
        totalAssets: 50000, totalLiabilities: 20000, netWorth: 30000,
      );
      expect(snapshot, equals(snapshot2));
    });

    test('toMap serializes correctly', () {
      final map = snapshot.toMap();
      expect(map['id'], 'nw-1');
      expect(map['date'], DateTime(2024, 6, 1).toIso8601String());
      expect(map['total_assets'], 50000);
      expect(map['total_liabilities'], 20000);
      expect(map['net_worth'], 30000);
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'id': 'nw-1', 'date': DateTime(2024, 6, 1).toIso8601String(),
        'total_assets': 50000, 'total_liabilities': 20000, 'net_worth': 30000,
      };
      final result = NetWorthSnapshot.fromMap(map);
      expect(result.id, 'nw-1');
      expect(result.date, DateTime(2024, 6, 1));
      expect(result.netWorth, 30000);
    });

    test('fromMap with negative net worth', () {
      final map = {
        'id': 'nw-2', 'date': now.toIso8601String(),
        'total_assets': 10000, 'total_liabilities': 25000, 'net_worth': -15000,
      };
      final result = NetWorthSnapshot.fromMap(map);
      expect(result.netWorth, -15000);
    });
  });
}
