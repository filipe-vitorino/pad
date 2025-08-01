import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _sessionKey = 'user_session_email';

  // Salva a sessão do usuário (neste caso, o email)
  Future<void> saveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, email);
    print("Sessão salva para o usuário: $email");
  }

  // Carrega a sessão do usuário
  Future<String?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionEmail = prefs.getString(_sessionKey);
    print("Verificando sessão. Usuário logado: $sessionEmail");
    return sessionEmail;
  }

  // Limpa a sessão (logout)
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    print("Sessão limpa. Usuário deslogado.");
  }

  // Método auxiliar para verificar rapidamente se o usuário está logado
  Future<bool> isLoggedIn() async {
    final session = await getSession();
    return session != null;
  }
}
