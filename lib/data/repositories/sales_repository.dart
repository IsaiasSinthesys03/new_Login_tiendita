import 'package:sqflite/sqflite.dart';
import '../../core/models/sale.dart';
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
          'is_returned': 0, 
          'returned_quantity': 0,
          'return_reason': null,
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

  Future<String?> recordPartialReturn({
    required int saleItemId,
    required String reason,
    required int quantity, // Cantidad a devolver
  }) async {
    final db = await DBHelper.instance.database;

    try {
      await db.transaction((txn) async {
        // 1. Obtener la información del ítem de venta
        final saleItemRes = await txn.query('sale_items', where: 'id = ?', whereArgs: [saleItemId]);
        if (saleItemRes.isEmpty) {
          throw Exception('Item de venta no encontrado');
        }
        final item = SaleItem.fromMap(saleItemRes.first);
        
        final currentReturnedQty = item.returnedQuantity ?? 0;
        final newReturnedQty = currentReturnedQty + quantity;

        // Validación: No se puede devolver más de lo vendido menos lo ya devuelto
        if (newReturnedQty > item.quantity) {
             throw Exception('La cantidad a devolver excede la cantidad vendida (${item.quantity - currentReturnedQty})');
        }

        // 2. Marcar el ítem como devuelto y la razón
        await txn.update('sale_items', {
          'is_returned': newReturnedQty == item.quantity ? 1 : 0, 
          'returned_quantity': newReturnedQty,
          'return_reason': reason,
        }, where: 'id = ?', whereArgs: [saleItemId]);

        // 3. Devolver el stock del producto
        final prodRes = await txn.query('products', where: 'id = ?', whereArgs: [item.productId]);
        final currentStock = prodRes.first['stock'] as int;
        final newStock = currentStock + quantity;

        await txn.update('products', {
          'stock': newStock,
        }, where: 'id = ?', whereArgs: [item.productId]);
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }
  
  /// Reporte del día: lista de partidas y total
  Future<(List<Map<String, dynamic>> rows, double total)> dailyReport(DateTime day) async {
    final db = await DBHelper.instance.database;
    final start = DateTime(day.year, day.month, day.day).toIso8601String();
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59).toIso8601String();

    final rows = await db.rawQuery('''
      SELECT si.id, p.name, si.quantity, si.unit_price, s.created_at, si.is_returned, si.return_reason, si.returned_quantity
      FROM sale_items si
      JOIN sales s ON s.id = si.sale_id
      JOIN products p ON p.id = si.product_id
      WHERE s.created_at BETWEEN ? AND ?
      ORDER BY s.created_at DESC
    ''', [start, end]);

    double total = 0;
    for (final r in rows) {
      final qtySold = (r['quantity'] as int);
      final qtyReturned = (r['returned_quantity'] as int) ?? 0;
      final price = (r['unit_price'] as num).toDouble();
      
      total += (qtySold - qtyReturned) * price;
    }
    return (rows, total);
  }
}