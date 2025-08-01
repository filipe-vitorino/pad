/*
 * Título: ViewModel da Tela de Login
 * Descrição: Gerencia o estado e a lógica de autenticação da tela de login.
 * Autor: Gemini
 * Data: 01 de Agosto de 2025
*/

import 'package:flutter/material.dart';
import '../services/session_service.dart'; // Importe o novo serviço

class LoginViewModel extends ChangeNotifier {
  final SessionService _sessionService =
      SessionService(); // Instancie o serviço

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
      // ===== MUDANÇA IMPORTANTE AQUI =====
      // Se o login for um sucesso, salve a sessão!
      await _sessionService.saveSession(email);
      // ===================================

      _isLoading = false;
      notifyListeners();
      return true;
    }
  }
}
