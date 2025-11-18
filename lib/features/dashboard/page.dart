import 'package:flutter/material.dart';
import 'package:iot_lab4/core/app_routes.dart';
import 'package:iot_lab4/core/service_locator.dart';
import 'package:iot_lab4/services/connectivity_service.dart';
import 'package:iot_lab4/services/mqtt_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<MqttService>().connect();
  }

  @override
  void dispose() {
    context.read<MqttService>().disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mqttStatus = context.watch<MqttService>().status;
    final netStatus = context.watch<ConnectivityStatus>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (netStatus == ConnectivityStatus.offline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.red,
                child: const Text(
                  'No Internet Connection',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            const SizedBox(height: 16),
            _buildMqttStatusCard(mqttStatus),
            const SizedBox(height: 24),
            _buildLiveDataCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMqttStatusCard(MqttStatus status) {
    IconData icon;
    String text;
    Color color;

    switch (status) {
      case MqttStatus.connected:
        icon = Icons.check_circle;
        text = 'Connected to Broker';
        color = Colors.green;
        break;
      case MqttStatus.connecting:
        icon = Icons.hourglass_empty;
        text = 'Connecting...';
        color = Colors.orange;
        break;
      case MqttStatus.disconnected:
        icon = Icons.error;
        text = 'Disconnected';
        color = Colors.red;
        break;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(text, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveDataCard() {
    // "Слухаємо" лише температуру
    // ОСЬ ТУТ БУЛА ПОМИЛКА: MMqttService -> MqttService
    final temp = context.watch<MqttService>().currentTemperature;

    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Live Temperature (from sensor/temperature)',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(
              '$temp °C',
              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}