import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/user_repository.dart';
import '../core/models/user.dart'; // RUTA CORREGIDA

class AuthProvider with ChangeNotifier {
  final _repo = UserRepository();
  AppUser? _current;

  AppUser? get current => _current;

  Future<void> loadSessionIfAny() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('logged_username');
    if (username != null) {
      _current = await _repo.getByUsername(username);
      notifyListeners();
    }
  }

  String _hash(String plain) => sha256.convert(utf8.encode(plain)).toString();

  Future<String?> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final exists = await _repo.getByUsername(username);
      if (exists != null) return 'El usuario ya existe';
      final user = AppUser(
        fullName: fullName,
        username: username,
        email: email,
        passwordHash: _hash(password),
      );
      await _repo.create(user);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login(String username, String password) async {
    final user = await _repo.getByUsername(username);
    if (user == null) return 'Usuario o contraseña inválidos';
    if (user.passwordHash != _hash(password)) return 'Usuario o contraseña inválidos';
    _current = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logged_username', user.username);
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_username');
    _current = null;
    notifyListeners();
  }
}