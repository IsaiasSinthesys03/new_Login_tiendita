import 'package:flutter/material.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/sales_repository.dart';
import '../models/product.dart';

class SalesProvider with ChangeNotifier {
  final _productsRepo = ProductRepository();
  final _salesRepo = SalesRepository();

  /// estado de venta actual (en memoria)
  final Map<int, (Product product, int qty)> _current = {};

  Map<int, (Product, int)> get current => _current;

  Future<List<Product>> availableProducts() async {
    final all = await _productsRepo.getAll();
    return all.where((p) => !_current.keys.contains(p.id)).toList();
  }

  void addToCurrent(Product p, int qty) {
    _current[p.id!] = (p, qty);
    notifyListeners();
  }

  void updateQty(int productId, int qty) {
    if (_current.containsKey(productId)) {
      final p = _current[productId]!.$1;
      _current[productId] = (p, qty);
      notifyListeners();
    }
  }

  void removeFromCurrent(int productId) {
    _current.remove(productId);
    notifyListeners();
  }

  double get total {
    double t = 0;
    for (final entry in _current.values) {
      t += entry.$1.unitPrice * entry.$2;
    }
    return t;
  }

  Future<String?> commitSale() async {
    if (_current.isEmpty) return 'Agrega al menos un producto';
    try {
      final items = _current.entries.map((e) => {
            'productId': e.key,
            'quantity': e.value.$2,
            'unitPrice': e.value.$1.unitPrice,
          }).toList();
      await _salesRepo.createSale(when: DateTime.now(), items: items);
      _current.clear();
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
