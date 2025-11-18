import 'package:flutter/material.dart';
import 'package:iot_lab4/core/app_routes.dart';
import 'package:iot_lab4/data/models/sensor.dart';
import 'package:iot_lab4/data/repositories/api_sensor_repository.dart';
import 'package:iot_lab4/data/repositories/local_sensor_repository.dart';
import 'package:iot_lab4/services/connectivity_service.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Підключаємо два джерела даних
  final ApiSensorRepository _apiRepository = ApiSensorRepository();
  final LocalSensorRepository _localRepository = LocalSensorRepository();
  
  late Future<List<Sensor>> _sensorsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _sensorsFuture = _fetchDataSmartly();
    });
  }

  // РОЗУМНА ЛОГІКА: Спочатку Інтернет -> потім Пам'ять
  Future<List<Sensor>> _fetchDataSmartly() async {
    final isOnline = await ConnectivityService.isOnline();

    if (isOnline) {
      try {
        // 1. Є інтернет? Качаємо свіжі дані
        final sensors = await _apiRepository.fetchSensors();
        // 2. Одразу зберігаємо їх у пам'ять (кешуємо)
        await _localRepository.saveSensors(sensors);
        return sensors;
      } catch (e) {
        // 3. Якщо помилка сервера - пробуємо показати старі дані з пам'яті
        return await _localRepository.getSensors();
      }
    } else {
      // 4. Немає інтернету? Беремо з пам'яті
      return await _localRepository.getSensors();
    }
  }

  @override
  Widget build(BuildContext context) {
    final netStatus = Provider.of<ConnectivityStatus>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData, // Кнопка оновлення
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Червона плашка, якщо офлайн
          if (netStatus == ConnectivityStatus.offline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.red[400],
              child: const Text(
                'OFFLINE MODE: Using cached data',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),

          // Список даних
          Expanded(
            child: FutureBuilder<List<Sensor>>(
              future: _sensorsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data found. Connect to internet.'));
                }

                final sensors = snapshot.data!;
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sensors.length,
                  itemBuilder: (context, index) {
                    final sensor = sensors[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            sensor.iconKey == 'kitchen' ? Icons.kitchen : Icons.desktop_windows,
                          ),
                        ),
                        title: Text(sensor.roomName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Temp: ${sensor.temp}°C | CO2: ${sensor.co2} ppm'),
                        trailing: Text('${sensor.humidity}%'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}