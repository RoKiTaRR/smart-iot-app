import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iot_lab4/data/models/user.dart';
import 'package:iot_lab4/data/repositories/auth_repository.dart';

// Логіка автентифікації, тепер з SecureStorage
class LocalAuthRepository implements AuthRepository {
  final _storage = const FlutterSecureStorage();

  static const String _kUserSessionToken = 'user_session_token';
  static const String _kUserName = 'user_name';
  static const String _kUserEmail = 'user_email';
  static const String _kUserPassword = 'user_password'; // Тільки для лаби

  @override
  Future<void> register(User user) async {
    await _storage.write(key: _kUserName, value: user.name);
    await _storage.write(key: _kUserEmail, value: user.email);
    await _storage.write(key: _kUserPassword, value: user.password);
  }

  @override
  Future<User?> login(String email, String password) async {
    final storedEmail = await _storage.read(key: _kUserEmail);
    final storedPassword = await _storage.read(key: _kUserPassword);

    if (email == storedEmail && password == storedPassword) {
      final storedName = await _storage.read(key: _kUserName) ?? 'No Name';
      
      // Створюємо "токен сесії"
      final sessionToken = 'fake_token_for_${email}';
      await _storage.write(key: _kUserSessionToken, value: sessionToken);

      return User(name: storedName, email: email, password: password);
    }
    return null;
  }

  @override
  Future<User?> getLoggedInUser() async {
    // Перевіряємо, чи є ТОКЕН
    final token = await _storage.read(key: _kUserSessionToken);
    if (token != null) {
      final name = await _storage.read(key: _kUserName) ?? 'No Name';
      final email = await _storage.read(key: _kUserEmail) ?? 'No Email';
      return User(name: name, email: email, password: '');
    }
    return null;
  }

  @override
  Future<void> logout() async {
    // Видаляємо ЛИШЕ токен
    await _storage.delete(key: _kUserSessionToken);
  }
}