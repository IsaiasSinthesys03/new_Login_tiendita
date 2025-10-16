import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/user_repository.dart';
import '../core/models/user.dart'; // RUTA CORREGIDA

enum LoginStatus { init, loading, success, failure }

class AuthProvider with ChangeNotifier {
  final _repo = UserRepository();
  AppUser? _current;
  LoginStatus _loginStatus = LoginStatus.init;
  String? _errorMessage;

  AppUser? get current => _current;
  LoginStatus get loginStatus => _loginStatus;
  String? get errorMessage => _errorMessage;

  Future<void> loadSessionIfAny() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('logged_email');
    if (email != null) {
      _current = await _repo.getByEmail(email);
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
      final exists = await _repo.getByEmail(email);
      if (exists != null) return 'El correo electrónico ya está registrado';
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

  Future<void> login(String email, String password) async {
    _loginStatus = LoginStatus.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final user = await _repo.getByEmail(email);
      if (user == null) {
        _loginStatus = LoginStatus.failure;
        _errorMessage = 'Credenciales incorrectas. Verifica tu correo y contraseña.';
        notifyListeners();
        return;
      }
      
      if (user.passwordHash != _hash(password)) {
        _loginStatus = LoginStatus.failure;
        _errorMessage = 'Credenciales incorrectas. Verifica tu correo y contraseña.';
        notifyListeners();
        return;
      }
      
      _current = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logged_email', user.email);
      _loginStatus = LoginStatus.success;
      notifyListeners();
    } catch (e) {
      _loginStatus = LoginStatus.failure;
      _errorMessage = 'Error interno del sistema. No se pudo verificar la base de datos.';
      notifyListeners();
    }
  }

  void clearError() {
    _loginStatus = LoginStatus.init;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_email');
    _current = null;
    _loginStatus = LoginStatus.init;
    _errorMessage = null;
    notifyListeners();
  }
}