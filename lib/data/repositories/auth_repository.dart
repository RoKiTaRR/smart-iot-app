import 'package:smart_iot_app/data/models/user.dart';

abstract class AuthRepository {
  Future<void> register(User user);
  Future<User?> login(String email, String password);
  Future<User?> getLoggedInUser();
  Future<void> logout();
}
