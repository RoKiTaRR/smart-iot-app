import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_iot_app/data/models/user.dart';
import 'package:smart_iot_app/data/repositories/auth_repository.dart';

// Authentication logic using SharedPreferences for web compatibility
class LocalAuthRepository implements AuthRepository {
  static const String _kUserSessionToken = 'user_session_token';
  static const String _kUserName = 'user_name';
  static const String _kUserEmail = 'user_email';
  static const String _kUserPassword = 'user_password'; // Only for demo

  @override
  Future<void> register(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserName, user.name);
    await prefs.setString(_kUserEmail, user.email);
    await prefs.setString(_kUserPassword, user.password);
  }

  @override
  Future<User?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(_kUserEmail);
    final storedPassword = prefs.getString(_kUserPassword);

    if (email == storedEmail && password == storedPassword) {
      final storedName = prefs.getString(_kUserName) ?? 'No Name';

      // Create 'session token'
      final sessionToken = 'fake_token_for_';
      await prefs.setString(_kUserSessionToken, sessionToken);

      return User(name: storedName, email: email, password: password);
    }
    return null;
  }

  @override
  Future<User?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    // Check if TOKEN exists
    final token = prefs.getString(_kUserSessionToken);
    if (token != null) {
      final name = prefs.getString(_kUserName) ?? 'No Name';
      final email = prefs.getString(_kUserEmail) ?? 'No Email';
      return User(name: name, email: email, password: '');
    }
    return null;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Remove ONLY token
    await prefs.remove(_kUserSessionToken);
  }
}
