import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/features/attachments/domain/entities/attachment.dart';

void main() {
  group('Attachment', () {
    final now = DateTime(2024, 6, 15);
    final attachment = Attachment(
      id: 'a-1',
      transactionId: 'tx-1',
      transactionType: 'expense',
      filePath: '/storage/receipts/receipt.jpg',
      fileName: 'receipt.jpg',
      fileSize: 1024,
      mimeType: 'image/jpeg',
      createdAt: now,
    );

    test('props are correct', () {
      expect(attachment.props, [
        'a-1', 'tx-1', 'expense', '/storage/receipts/receipt.jpg',
        'receipt.jpg', 1024, 'image/jpeg', now,
      ]);
    });

    test('toMap serializes correctly', () {
      final map = attachment.toMap();
      expect(map['id'], 'a-1');
      expect(map['transaction_id'], 'tx-1');
      expect(map['transaction_type'], 'expense');
      expect(map['file_path'], '/storage/receipts/receipt.jpg');
      expect(map['file_name'], 'receipt.jpg');
      expect(map['file_size'], 1024);
      expect(map['mime_type'], 'image/jpeg');
      expect(map['created_at'], now.toIso8601String());
    });

    test('fromMap deserializes correctly', () {
      final map = {
        'id': 'a-1',
        'transaction_id': 'tx-1',
        'transaction_type': 'expense',
        'file_path': '/storage/receipts/receipt.jpg',
        'file_name': 'receipt.jpg',
        'file_size': 1024,
        'mime_type': 'image/jpeg',
        'created_at': now.toIso8601String(),
      };
      final result = Attachment.fromMap(map);
      expect(result.id, 'a-1');
      expect(result.transactionId, 'tx-1');
      expect(result.transactionType, 'expense');
      expect(result.fileName, 'receipt.jpg');
      expect(result.mimeType, 'image/jpeg');
    });

    test('equality works', () {
      final attachment2 = Attachment(
        id: 'a-1', transactionId: 'tx-1', transactionType: 'expense',
        filePath: '/storage/receipts/receipt.jpg', fileName: 'receipt.jpg',
        fileSize: 1024, mimeType: 'image/jpeg', createdAt: now,
      );
      expect(attachment, equals(attachment2));
    });

    test('fromMap with null optional fields', () {
      final map = {
        'id': 'a-1', 'transaction_id': 'tx-1', 'transaction_type': 'expense',
        'file_path': '/path', 'file_name': 'file.txt',
        'file_size': null, 'mime_type': null,
        'created_at': now.toIso8601String(),
      };
      final result = Attachment.fromMap(map);
      expect(result.fileSize, isNull);
      expect(result.mimeType, isNull);
    });
  });
}
