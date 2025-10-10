import 'package:flutter/material.dart';
import '../data/repositories/product_repository.dart';
import '../core/models/product.dart';

class ProductsProvider with ChangeNotifier {
  final _repo = ProductRepository();
  List<Product> _items = [];

  List<Product> get items => _items;

  Future<void> refresh() async {
    _items = await _repo.getAll();
    notifyListeners();
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

  Future<String?> update(Product product) async {
    try {
      await _repo.update(product);
      await refresh();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> delete(int id) async {
    try {
      await _repo.delete(id);
      await refresh();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}