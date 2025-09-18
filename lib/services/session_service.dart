import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _sessionKey = 'user_session_email';
  static const String _lastSyncTimestampKey = 'last_sync_timestamp';

  Future<void> saveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, email);
  }

  Future<String?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_lastSyncTimestampKey);
  }

  Future<bool> isLoggedIn() async {
    final session = await getSession();
    return session != null;
  }

  Future<void> saveLastSyncTimestamp(int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncTimestampKey, timestamp);
  }

  Future<int> getLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastSyncTimestampKey) ?? 0;
  }
}
