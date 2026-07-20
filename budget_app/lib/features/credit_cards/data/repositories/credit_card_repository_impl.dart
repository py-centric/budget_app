import '../../domain/entities/credit_card.dart';
import '../../domain/repositories/credit_card_repository.dart';
import '../../../budget/data/datasources/local_database.dart';

class CreditCardRepositoryImpl implements CreditCardRepository {
  final LocalDatabase _localDatabase;

  CreditCardRepositoryImpl(this._localDatabase);

  @override
  Future<List<CreditCard>> getAllCreditCards() async {
    final db = await _localDatabase.database;
    final maps = await db.query('credit_cards', orderBy: 'name ASC');
    return maps.map(CreditCard.fromMap).toList();
  }

  @override
  Future<CreditCard?> getCreditCardById(String id) async {
    final db = await _localDatabase.database;
    final maps = await db.query('credit_cards', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return CreditCard.fromMap(maps.first);
  }

  @override
  Future<CreditCard> addCreditCard(CreditCard card) async {
    final db = await _localDatabase.database;
    await db.insert('credit_cards', card.toMap());
    return card;
  }

  @override
  Future<void> updateCreditCard(CreditCard card) async {
    final db = await _localDatabase.database;
    await db.update('credit_cards', card.toMap(), where: 'id = ?', whereArgs: [card.id]);
  }

  @override
  Future<void> deleteCreditCard(String id) async {
    final db = await _localDatabase.database;
    await db.delete('credit_cards', where: 'id = ?', whereArgs: [id]);
  }
}
