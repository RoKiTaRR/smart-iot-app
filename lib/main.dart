import 'package:flutter/material.dart';
import 'package:smart_iot_app/core/app_routes.dart';
import 'package:smart_iot_app/core/service_locator.dart';
import 'package:smart_iot_app/services/connectivity_service.dart';
import 'package:smart_iot_app/services/mqtt_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MqttService()),
        StreamProvider(
          create: (_) => ConnectivityService().connectionStream,
          initialData: ConnectivityStatus.online,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Air Quality Monitor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        fontFamily: 'Nunito',
      ),
      debugShowCheckedModeBanner: false,
      routes: AppRoutes.routes,
      initialRoute: AppRoutes.authCheck,
    );
  }
}
