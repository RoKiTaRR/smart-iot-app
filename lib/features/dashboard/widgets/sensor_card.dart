import 'package:flutter/material.dart';
import 'package:smart_iot_app/data/models/sensor.dart';

// Цей віджет більше не використовується на дашборді, але залишається з Лаби 3
class SensorCard extends StatelessWidget {
  const SensorCard({
    super.key,
    required this.sensor,
    required this.onDelete,
    required this.onTap,
  });

  final Sensor sensor;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  IconData _getIconData(String iconKey) {
    switch (iconKey) {
      case 'people':
        return Icons.people_outline;
      case 'kitchen':
        return Icons.kitchen_outlined;
      case 'desktop':
        return Icons.desktop_windows_outlined;
      default:
        return Icons.sensors;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Icon(_getIconData(sensor.iconKey), size: 40, color: Colors.blueGrey[600]),
        title: Text(
          sensor.roomName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'CO2: ${sensor.co2} ppm | Temp: ${sensor.temp}°C | Hum: ${sensor.humidity}%',
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
