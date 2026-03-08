import 'package:flutter/material.dart';
import 'package:smart_iot_app/core/app_routes.dart';
import 'package:smart_iot_app/data/models/sensor.dart';
import 'package:smart_iot_app/data/repositories/api_sensor_repository.dart';
import 'package:smart_iot_app/data/repositories/local_sensor_repository.dart';
import 'package:smart_iot_app/services/connectivity_service.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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

  Future<List<Sensor>> _fetchDataSmartly() async {
    try {
      // Спробуємо завантажити з API
      final sensors = await _apiRepository.fetchSensors();
      // Зберігаємо в кеш
      await _localRepository.saveSensors(sensors);
      return sensors;
    } catch (e) {
      debugPrint("API Error: $e");
      
      // Пробуємо дістати з пам'яті
      final cached = await _localRepository.getSensors();
      
      // ЯКЩО КЕШ ПУСТИЙ - ВИКИДАЄМО ПОМИЛКУ, ЩОБ ПОБАЧИТИ ЇЇ НА ЕКРАНІ
      if (cached.isEmpty) {
        throw Exception("$e"); 
      }
      
      return cached;
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
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (netStatus == ConnectivityStatus.offline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.red[400],
              child: const Text(
                'OFFLINE MODE',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),

          Expanded(
            child: FutureBuilder<List<Sensor>>(
              future: _sensorsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // ТУТ МИ ПОКАЖЕМО ТОЧНУ ПОМИЛКУ
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          const Text(
                            'Connection Error:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}', // Саме текст помилки
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: const Text('Try Again'),
                          )
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data found.'));
                }

                final sensors = snapshot.data!;
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sensors.length,
                  itemBuilder: (context, index) {
                    final sensor = sensors[index];
                    return _buildSensorCard(sensor);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(Sensor sensor) {
    IconData icon;
    if (sensor.iconKey == 'kitchen') {
      icon = Icons.kitchen;
    } else if (sensor.iconKey == 'desktop') {
      icon = Icons.desktop_windows;
    } else {
      icon = Icons.sensors;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueGrey[50],
          child: Icon(icon, color: Colors.blueGrey),
        ),
        title: Text(sensor.roomName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Temp: ${sensor.temp}°C | CO2: ${sensor.co2} ppm'),
        trailing: Text('${sensor.humidity}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
