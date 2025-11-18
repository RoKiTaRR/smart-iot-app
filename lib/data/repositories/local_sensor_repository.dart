import 'dart:convert';
import 'package:iot_lab4/data/models/sensor.dart';
import 'package:iot_lab4/data/repositories/sensor_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kSensorsKey = 'user_sensors';

// Ця реалізація залишається з Лаби 3
class LocalSensorRepository implements SensorRepository {
  @override
  Future<List<Sensor>> getSensors() async {
    final prefs = await SharedPreferences.getInstance();
    final sensorsStringList = prefs.getStringList(_kSensorsKey) ?? [];
    
    return sensorsStringList
        .map((jsonString) => Sensor.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  @override
  Future<void> saveSensors(List<Sensor> sensors) async {
    final prefs = await SharedPreferences.getInstance();
    
    final sensorsStringList = sensors
        .map((sensor) => jsonEncode(sensor.toJson()))
        .toList();
        
    await prefs.setStringList(_kSensorsKey, sensorsStringList);
  }

  @override
  Future<void> addSensor(Sensor sensor) async {
    final sensors = await getSensors();
    sensors.add(sensor);
    await saveSensors(sensors);
  }

  @override
  Future<void> deleteSensor(String id) async {
    final sensors = await getSensors();
    sensors.removeWhere((sensor) => sensor.id == id);
    await saveSensors(sensors);
  }

  @override
  Future<void> updateSensor(Sensor updatedSensor) async {
    final sensors = await getSensors();
    final index = sensors.indexWhere((sensor) => sensor.id == updatedSensor.id);
    if (index != -1) {
      sensors[index] = updatedSensor;
      await saveSensors(sensors);
    }
  }
}