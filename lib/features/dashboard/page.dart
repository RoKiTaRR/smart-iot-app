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
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _sensorsFuture = _fetchDataSmartly();
      _statsFuture = _apiRepository.fetchSensorStats();
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
        title: const Text('Smart IoT Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showStatsDialog(context),
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
                'OFFLINE MODE - Using cached data',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),

          // Статистика
          FutureBuilder<Map<String, dynamic>>(
            future: _statsFuture,
            builder: (context, statsSnapshot) {
              if (statsSnapshot.hasData && !statsSnapshot.data!.containsKey('error')) {
                final stats = statsSnapshot.data!;
                return Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Sensors', '${stats['totalSensors']}', Icons.sensors),
                      _buildStatItem('Avg Temp', '${stats['averageTemperature'].toStringAsFixed(1)}°C', Icons.thermostat),
                      _buildStatItem('Avg Humidity', '${stats['averageHumidity'].toStringAsFixed(0)}%', Icons.water_drop),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          Expanded(
            child: FutureBuilder<List<Sensor>>(
              future: _sensorsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
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
                            '${snapshot.error}',
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
                  return const Center(child: Text('No sensors found.'));
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[700]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSensorCard(Sensor sensor) {
    IconData icon;
    switch (sensor.iconKey) {
      case 'kitchen':
        icon = Icons.kitchen;
        break;
      case 'bed':
        icon = Icons.bed;
        break;
      case 'shower':
        icon = Icons.shower;
        break;
      case 'desktop':
        icon = Icons.desktop_windows;
        break;
      case 'garage':
        icon = Icons.garage;
        break;
      case 'balcony':
        icon = Icons.balcony;
        break;
      default:
        icon = Icons.home;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 32, color: sensor.statusColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sensor.roomName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        sensor.statusDescription,
                        style: TextStyle(
                          color: sensor.statusColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: sensor.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sensor.statusColor),
                  ),
                  child: Text(
                    sensor.status.toUpperCase(),
                    style: TextStyle(
                      color: sensor.statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricItem('CO₂', '${sensor.co2} ppm', Icons.co2),
                _buildMetricItem('Temp', '${sensor.temp}°C', Icons.thermostat),
                _buildMetricItem('Humidity', '${sensor.humidity}%', Icons.water_drop),
              ],
            ),
            if (sensor.lastUpdated != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Last updated: ${_formatDateTime(sensor.lastUpdated!)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[600], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sensor Statistics'),
        content: FutureBuilder<Map<String, dynamic>>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const Text('Failed to load statistics');
            }

            final stats = snapshot.data!;
            if (stats.containsKey('error')) {
              return Text('Error: ${stats['error']}');
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Sensors: ${stats['totalSensors']}'),
                Text('Average Temperature: ${stats['averageTemperature'].toStringAsFixed(1)}°C'),
                Text('Average Humidity: ${stats['averageHumidity'].toStringAsFixed(0)}%'),
                Text('Total CO₂: ${stats['totalCo2']} ppm'),
                if (stats['lastUpdated'] != null)
                  Text('Last Updated: ${DateTime.parse(stats['lastUpdated']).toLocal()}'),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
}
}
