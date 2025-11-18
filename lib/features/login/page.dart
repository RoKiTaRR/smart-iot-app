import 'package:flutter/material.dart';
import 'package:iot_lab4/core/app_routes.dart';
import 'package:iot_lab4/data/repositories/auth_repository.dart';
import 'package:iot_lab4/data/repositories/local_auth_repository.dart';
import 'package:iot_lab4/features/shared_widgets/custom_button.dart';
import 'package:iot_lab4/features/shared_widgets/custom_textfield.dart';
import 'package:iot_lab4/services/connectivity_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthRepository _authRepository = LocalAuthRepository();

  void _handleLogin() async {
    // Перевірка Інтернету
    final isOnline = await ConnectivityService.isOnline();
    if (!isOnline) {
      _showError('No internet connection');
      return;
    }

    final email = _emailController.text;
    final password = _passwordController.text;
    final user = await _authRepository.login(email, password);

    if (user != null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    } else {
      _showError('Invalid email or password');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.air, size: 80, color: Colors.blueGrey),
              const SizedBox(height: 16),
              const Text(
                'Office Air Monitor',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              CustomTextField(hintText: 'Email', controller: _emailController),
              CustomTextField(
                hintText: 'Password',
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Login',
                onPressed: _handleLogin,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.register);
                },
                child: const Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}