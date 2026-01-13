// lib/providers/auth_provider.dart
// UPDATED - Supports role selection in login

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isLoggedIn = false;

  // Getters
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _checkAuthStatus();
  }

  /// Login with username, password, and selected role
  Future<bool> login({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      if (username.trim().isEmpty || password.isEmpty) {
        _errorMessage = 'Username dan password harus diisi';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // MOCK DATA - Replace with API when ready
      final mockUsers = {
        'admin': User(
          id: '1',
          name: 'Admin SIMRS',
          email: 'admin@simrs.com',
          username: 'admin',
          role: UserRole.admin,
          createdAt: DateTime.now(),
        ),
        'dokter': User(
          id: '2',
          name: 'Dr. Budi Santoso',
          email: 'dokter@simrs.com',
          username: 'dokter',
          role: UserRole.doctor,
          createdAt: DateTime.now(),
        ),
        'coder': User(
          id: '3',
          name: 'Coder Medis',
          email: 'coder@simrs.com',
          username: 'coder',
          role: UserRole.coder,
          createdAt: DateTime.now(),
        ),
        'auditor': User(
          id: '4',
          name: 'Auditor SIMRS',
          email: 'auditor@simrs.com',
          username: 'auditor',
          role: UserRole.auditor,
          createdAt: DateTime.now(),
        ),
      };

      var user = mockUsers[username.trim()];

      if (user != null && password == '123456') {
        // Apply selected role
        user = user.copyWith(role: role);
        _currentUser = user;
        _token =
            'mock_token_${username}_${DateTime.now().millisecondsSinceEpoch}';
        _isLoggedIn = true;
        _errorMessage = '';

        await _saveAuthToken(_token!);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Username atau password salah';
        _isLoggedIn = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _isLoggedIn = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _isLoggedIn = false;
    _errorMessage = '';
    await _clearAuthData();
    notifyListeners();
  }

  bool hasRole(UserRole role) => _currentUser?.role == role;

  String getUserGreeting() {
    final hour = DateTime.now().hour;
    String greeting =
        hour < 12
            ? 'Selamat Pagi'
            : hour < 15
            ? 'Selamat Siang'
            : hour < 18
            ? 'Selamat Sore'
            : 'Selamat Malam';
    return '$greeting, ${_currentUser?.name ?? 'User'}!';
  }

  // Private methods
  Future<void> _saveAuthToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      if (_currentUser != null) {
        await prefs.setString('user_id', _currentUser!.id);
        await prefs.setString('user_role', _currentUser!.role.name);
      }
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('user_role');
    } catch (e) {
      debugPrint('Error clearing auth: $e');
    }
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        _token = token;
        _isLoggedIn = true;
      }
    } catch (e) {
      debugPrint('Error checking auth: $e');
    }
    notifyListeners();
  }
}
