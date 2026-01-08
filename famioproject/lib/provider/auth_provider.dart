import 'package:flutter/material.dart';
import '../services/auth_services.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _role;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get role => _role;

  Future<void> login({
    required String email,
    required String password,
    required String selectedRole,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final roleFromDB = await _authService.loginUser(
        email: email,
        password: password,
      );

      if (roleFromDB != selectedRole) {
        throw Exception("Selected role does not match account role");
      }

      _role = roleFromDB;
      _isLoggedIn = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _isLoggedIn = false;
    _role = null;
    notifyListeners();
  }
}
