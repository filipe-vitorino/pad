import 'package:flutter/material.dart';
import '../services/session_service.dart';

class LoginViewModel extends ChangeNotifier {
  final SessionService _sessionService = SessionService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    if (email.isEmpty || password.isEmpty) {
      _errorMessage = "Utilizador e senha não podem estar vazios.";
      _isLoading = false;
      notifyListeners();
      return false;
    } else {
      await _sessionService.saveSession(email);
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }
}
