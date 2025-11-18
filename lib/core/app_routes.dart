import 'package:flutter/material.dart';
import 'package:iot_lab4/features/auth_check/page.dart';
import 'package:iot_lab4/features/dashboard/page.dart';
import 'package:iot_lab4/features/login/page.dart';
import 'package:iot_lab4/features/profile/page.dart';
import 'package:iot_lab4/features/registration/page.dart';

class AppRoutes {
  static const String authCheck = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes {
    return {
      authCheck: (context) => const AuthCheckPage(),
      login: (context) => const LoginPage(),
      register: (context) => const RegistrationPage(),
      dashboard: (context) => const DashboardPage(),
      profile: (context) => const ProfilePage(),
    };
  }
}