import 'package:iot_lab4/data/models/sensor.dart';

// Ця абстракція залишається з Лаби 3
abstract class SensorRepository {
  Future<List<Sensor>> getSensors();
  Future<void> saveSensors(List<Sensor> sensors);
  Future<void> addSensor(Sensor sensor);
  Future<void> deleteSensor(String id);
  Future<void> updateSensor(Sensor sensor);
}