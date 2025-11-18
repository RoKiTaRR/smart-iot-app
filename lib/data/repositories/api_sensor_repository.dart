import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:iot_lab4/data/models/sensor.dart'; 

class ApiSensorRepository {
  // Використовуємо JSONPlaceholder для імітації бекенду
  final String _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Sensor>> fetchSensors() async {
    try {
      // Запитуємо 5 "постів", які перетворимо на сенсори
      final response = await http.get(Uri.parse('$_baseUrl/posts?_limit=5'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Перетворюємо JSON у список Sensor
        return data.map((json) => Sensor.fromApi(json)).toList();
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }
}