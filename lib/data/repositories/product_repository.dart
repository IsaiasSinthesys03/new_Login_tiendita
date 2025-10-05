import 'package:sqflite/sqflite.dart';
import '../../models/product.dart';
import '../local/db_helper.dart';

class ProductRepository {
  Future<List<Product>> getAll() async {
    final db = await DBHelper.instance.database;
    final res = await db.query('products', orderBy: 'name ASC');
    return res.map((e) => Product.fromMap(e)).toList();
  }

  /// Regla de stock inteligente:
  /// Si (name, unit_price) coincide, suma stock; si cambia alguno, crea producto nuevo.
  Future<void> upsertSmart({required String name, required double unitPrice, required int quantity}) async {
    final db = await DBHelper.instance.database;
    final existing = await db.query('products',
        where: 'name = ? AND unit_price = ?', whereArgs: [name, unitPrice]);
    if (existing.isNotEmpty) {
      final p = Product.fromMap(existing.first);
      await db.update('products', p.copyWith(stock: p.stock + quantity).toMap(),
          where: 'id = ?', whereArgs: [p.id]);
    } else {
      await db.insert('products',
          Product(name: name, unitPrice: unitPrice, stock: quantity).toMap());
    }
  }

  Future<void> reduceStock({required int productId, required int quantity}) async {
    final db = await DBHelper.instance.database;
    final res = await db.query('products', where: 'id = ?', whereArgs: [productId]);
    if (res.isEmpty) throw Exception('Producto no encontrado');
    final p = Product.fromMap(res.first);
    if (p.stock < quantity) throw Exception('Stock insuficiente');
    await db.update('products', p.copyWith(stock: p.stock - quantity).toMap(),
        where: 'id = ?', whereArgs: [productId]);
  }
}
