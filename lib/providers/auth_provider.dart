// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  AuthProvider() {
    _checkAuthStatus();
  }

  /// ✅ SIMPLE ROLE-BASED LOGIN (FOR PROTOTYPE)
  Future<bool> login({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800)); // simulasi API

    if (username.isEmpty || password.isEmpty) {
      _errorMessage = 'Username dan password harus diisi';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // 🔑 SATU AKUN GLOBAL
    if (username == 'simrs' && password == '123456') {
      _currentUser = User(
        id: 'SIMRS-001',
        name: _roleName(role),
        username: username,
        email: 'simrs@hospital.id',
        role: role,
        createdAt: DateTime.now(),
      );

      _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      _isLoggedIn = true;

      await _saveSession();

      _isLoading = false;
      notifyListeners();
      return true;
    }

    _errorMessage = 'Username atau password salah';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _isLoggedIn = false;
    await _clearSession();
    notifyListeners();
  }

  // ================= UTIL =================

  String _roleName(UserRole role) {
    switch (role) {
      case UserRole.doctor:
        return 'Dokter';
      case UserRole.coder:
        return 'Coder Medis';
      case UserRole.auditor:
        return 'Auditor';
      case UserRole.admin:
        return 'Admin SIMRS';
    }
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', _token!);
    await prefs.setString('user_role', _currentUser!.role.name);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final role = prefs.getString('user_role');

    if (token != null && role != null) {
      _token = token;
      _currentUser = User(
        id: 'SIMRS-001',
        name: _roleName(UserRole.values.byName(role)),
        username: 'simrs',
        email: 'simrs@hospital.id',
        role: UserRole.values.byName(role),
        createdAt: DateTime.now(),
      );
      _isLoggedIn = true;
    }

    notifyListeners();
  }
}
