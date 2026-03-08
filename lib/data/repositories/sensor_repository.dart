import 'package:smart_iot_app/data/models/sensor.dart';

// Ця абстракція залишається з Лаби 3
abstract class SensorRepository {
  Future<List<Sensor>> getSensors();
  Future<void> saveSensors(List<Sensor> sensors);
  Future<void> addSensor(Sensor sensor);
  Future<void> deleteSensor(String id);
  Future<void> updateSensor(Sensor sensor);
}
