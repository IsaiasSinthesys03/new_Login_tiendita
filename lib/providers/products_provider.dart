import 'package:flutter/material.dart';
import '../data/repositories/product_repository.dart';
import '../models/product.dart';

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
}
