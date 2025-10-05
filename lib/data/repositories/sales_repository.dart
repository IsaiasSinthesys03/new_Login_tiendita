import 'package:sqflite/sqflite.dart';
import '../../models/sale.dart';
import '../local/db_helper.dart';

class SalesRepository {
  Future<int> createSale({
    required DateTime when,
    required List<Map<String, dynamic>> items, // {productId, quantity, unitPrice}
  }) async {
    final db = await DBHelper.instance.database;
    return await db.transaction<int>((txn) async {
      final saleId = await txn.insert('sales', {'created_at': when.toIso8601String()});
      for (final it in items) {
        await txn.insert('sale_items', {
          'sale_id': saleId,
          'product_id': it['productId'],
          'quantity': it['quantity'],
          'unit_price': it['unitPrice'],
        });
        // reducir stock
        final prod = await txn.query('products', where: 'id = ?', whereArgs: [it['productId']]);
        final stock = prod.first['stock'] as int;
        final newStock = stock - (it['quantity'] as int);
        if (newStock < 0) throw Exception('Stock insuficiente');
        await txn.update('products', {'stock': newStock}, where: 'id = ?', whereArgs: [it['productId']]);
      }
      return saleId;
    });
  }

  /// Reporte del día: lista de partidas y total
  Future<(List<Map<String, dynamic>> rows, double total)> dailyReport(DateTime day) async {
    final db = await DBHelper.instance.database;
    final start = DateTime(day.year, day.month, day.day).toIso8601String();
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59).toIso8601String();

    final rows = await db.rawQuery('''
      SELECT p.name, si.quantity, si.unit_price, s.created_at
      FROM sale_items si
      JOIN sales s ON s.id = si.sale_id
      JOIN products p ON p.id = si.product_id
      WHERE s.created_at BETWEEN ? AND ?
      ORDER BY s.created_at DESC
    ''', [start, end]);

    double total = 0;
    for (final r in rows) {
      total += (r['quantity'] as int) * (r['unit_price'] as num).toDouble();
    }
    return (rows, total);
  }
}
