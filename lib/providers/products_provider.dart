import 'package:flutter/material.dart';
import '../data/repositories/product_repository.dart';
import '../core/models/product.dart';

class ProductsProvider with ChangeNotifier {
  final _repo = ProductRepository();
  List<Product> _items = [];

  List<Product> get items => _items;

  // CORRECCIÓN: El método refresh ahora devuelve Future<List<Product>> y actualiza _items.
  Future<List<Product>> refresh() async {
    _items = await _repo.getAll();
    notifyListeners();
    return _items;
  }

  Future<String?> addSmart(String name, double price, int qty) async {
    try {
      await _repo.upsertSmart(name: name, unitPrice: price, quantity: qty);
      await refresh();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}