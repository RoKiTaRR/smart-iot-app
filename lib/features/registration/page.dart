import 'package:flutter/material.dart';
import 'package:smart_iot_app/data/models/user.dart';
import 'package:smart_iot_app/data/repositories/auth_repository.dart';
import 'package:smart_iot_app/data/repositories/local_auth_repository.dart';
import 'package:smart_iot_app/features/shared_widgets/custom_button.dart';
import 'package:smart_iot_app/features/shared_widgets/custom_textfield.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final AuthRepository _authRepository = LocalAuthRepository();

  void _handleRegister() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('All fields are required');
      return;
    }
    if (!email.contains('@')) {
      _showError('Invalid email format');
      return;
    }
    if (name.contains(RegExp(r'[0-9]'))) {
      _showError('Name cannot contain numbers');
      return;
    }

    final user = User(name: name, email: email, password: password);
    await _authRepository.register(user);

    if (mounted) {
      Navigator.pop(context);
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
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(hintText: 'Your Name', controller: _nameController),
            CustomTextField(hintText: 'Email', controller: _emailController),
            CustomTextField(
              hintText: 'Password',
              isPassword: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Register',
              onPressed: _handleRegister,
            ),
          ],
        ),
      ),
    );
  }
}
