import 'package:flutter/material.dart';
import 'package:smart_iot_app/core/app_routes.dart';
import 'package:smart_iot_app/data/models/user.dart';
import 'package:smart_iot_app/data/repositories/auth_repository.dart';
import 'package:smart_iot_app/data/repositories/local_auth_repository.dart';
import 'package:smart_iot_app/features/shared_widgets/custom_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthRepository _authRepository = LocalAuthRepository();
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = await _authRepository.getLoggedInUser();
    setState(() {
      _user = user;
    });
  }

  void _handleLogout() async {
    // Діалог підтвердження виходу
    final bool? didConfirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (didConfirm == true) {
      await _authRepository.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user!.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _user!.email,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const Spacer(),
                  CustomButton(
                    text: 'Logout',
                    onPressed: _handleLogout,
                  ),
                ],
              ),
            ),
    );
  }
}
