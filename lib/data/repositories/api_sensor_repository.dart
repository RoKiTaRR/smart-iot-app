import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:smart_iot_app/data/models/sensor.dart';

class ApiSensorRepository {
  // Використовуємо JSONPlaceholder для симуляції IoT API
  final String _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Sensor>> fetchSensors() async {
    try {
      // Отримуємо пости як основу для сенсорів
      final response = await http.get(Uri.parse('$_baseUrl/posts?_limit=8'));

      if (response.statusCode == 200) {
        final List<dynamic> posts = jsonDecode(response.body);

        return posts.map((post) {
          final int postId = post['id'];
          final String title = post['title'];

          // Створюємо сенсор на основі посту
          return Sensor.fromApi({
            'id': postId,
            'title': title,
            'userId': post['userId'],
          });
        }).toList();
      } else {
        print('Server error ${response.statusCode}, using Mock data');
        return _getMockData();
      }
    } catch (e) {
      print('Network exception: $e, using Mock data');
      return _getMockData();
    }
  }

  // Метод для отримання конкретного сенсора
  Future<Sensor> fetchSensorById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/posts/$id'));

      if (response.statusCode == 200) {
        final post = jsonDecode(response.body);
        return Sensor.fromApi({
          'id': post['id'],
          'title': post['title'],
          'userId': post['userId'],
        });
      } else {
        throw Exception('Sensor not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch sensor: $e');
    }
  }

  // Метод для оновлення сенсора (PUT запит)
  Future<Sensor> updateSensor(String id, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/posts/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final updatedPost = jsonDecode(response.body);
        return Sensor.fromApi({
          'id': updatedPost['id'],
          'title': updatedPost['title'] ?? 'Updated Room',
          'userId': updatedPost['userId'],
        });
      } else {
        throw Exception('Failed to update sensor');
      }
    } catch (e) {
      throw Exception('Failed to update sensor: $e');
    }
  }

  // Метод для отримання статистики сенсорів
  Future<Map<String, dynamic>> fetchSensorStats() async {
    try {
      final sensors = await fetchSensors();

      double avgTemp = sensors.map((s) => s.temp).reduce((a, b) => a + b) / sensors.length;
      double avgHumidity = sensors.map((s) => s.humidity).reduce((a, b) => a + b) / sensors.length;
      int totalCo2 = sensors.map((s) => s.co2).reduce((a, b) => a + b);

      return {
        'totalSensors': sensors.length,
        'averageTemperature': avgTemp,
        'averageHumidity': avgHumidity,
        'totalCo2': totalCo2,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': 'Failed to calculate stats: $e',
        'totalSensors': 0,
      };
    }
  }

  // ПЛАН Б: Розширена генерація mock даних з реалістичними показниками
  List<Sensor> _getMockData() {
    final random = Random();
    final roomTypes = ['Living Room', 'Kitchen', 'Bedroom', 'Bathroom', 'Office', 'Garage', 'Hallway', 'Balcony'];

    return List<Sensor>.generate(8, (index) {
      // Реалістичні діапазони для IoT сенсорів
      final baseTemp = 18.0 + random.nextDouble() * 12.0; // 18-30°C
      final humidity = 30 + random.nextInt(40); // 30-70%
      final co2 = 350 + random.nextInt(800); // 350-1150 ppm

      return Sensor(
        id: 'mock_${index + 1}',
        roomName: roomTypes[index % roomTypes.length],
        co2: co2,
        temp: double.parse(baseTemp.toStringAsFixed(1)),
        humidity: humidity,
        iconKey: _getIconForRoom(roomTypes[index % roomTypes.length]),
        lastUpdated: DateTime.now().subtract(Duration(minutes: random.nextInt(60))),
        status: co2 > 1000 ? 'warning' : 'normal',
      );
    });
  }

  String _getIconForRoom(String roomType) {
    switch (roomType.toLowerCase()) {
      case 'kitchen':
        return 'kitchen';
      case 'bedroom':
        return 'bed';
      case 'bathroom':
        return 'shower';
      case 'office':
        return 'desktop';
      case 'garage':
        return 'garage';
      case 'balcony':
        return 'balcony';
      default:
        return 'home';
    }
  }
}
