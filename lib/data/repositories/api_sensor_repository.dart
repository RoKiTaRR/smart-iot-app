import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_iot_app/data/models/sensor.dart';

class ApiSensorRepository {
  final String _url = 'https://randomuser.me/api/?results=5&nat=us';

  Future<List<Sensor>> fetchSensors() async {
    try {
      // 1. Пробуємо чесно сходити в інтернет
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> results = jsonResponse['results'];
        
        return results.map((item) {
           final String name = item['name']['first'].toString();
           final String roomName = "${name[0].toUpperCase()}${name.substring(1)} Room";
           
           return Sensor.fromApi({
             'id': 0, // ID згенерується у fromApi або тут
             'title': roomName,
           });
        }).toList();
      } else {
        // Якщо сервер помилився - вмикаємо план Б
        print('Server error ${response.statusCode}, using Mock data');
        return _getMockData();
      }
    } catch (e) {
      // Якщо інтернету немає взагалі - вмикаємо план Б
      print('Network exception: $e, using Mock data');
      return _getMockData();
    }
  }

  // ПЛАН Б: Генерація даних, якщо інтернет не працює
  List<Sensor> _getMockData() {
    return List<Sensor>.generate(5, (index) {
      return Sensor(
        id: 'mock_$index',
        roomName: 'Mock Room ${index + 1}',
        co2: 400 + (index * 50),
        temp: 20.0 + index,
        humidity: 40 + (index * 2),
        iconKey: index % 2 == 0 ? 'kitchen' : 'desktop',
      );
    });
  }
}
