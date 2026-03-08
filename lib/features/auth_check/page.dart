import 'package:flutter/material.dart';
import 'package:smart_iot_app/core/app_routes.dart';
import 'package:smart_iot_app/data/repositories/auth_repository.dart';
import 'package:smart_iot_app/data/repositories/local_auth_repository.dart';

// Цей екран перевіряє, чи є збережена сесія (авто-логін)
class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  final AuthRepository _authRepository = LocalAuthRepository();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 1)); // Імітація завантаження

    final user = await _authRepository.getLoggedInUser();
    
    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Checking session...'),
          ],
        ),
      ),
    );
  }
}
