import 'package:flutter/material.dart';

class Sensor {
  Sensor({
    required this.id,
    required this.roomName,
    required this.co2,
    required this.temp,
    required this.humidity,
    required this.iconKey,
    this.lastUpdated,
    this.status = 'normal',
  });

  final String id;
  String roomName;
  int co2;
  double temp;
  int humidity;
  String iconKey;
  DateTime? lastUpdated;
  String status; // 'normal', 'warning', 'critical'

  // Для збереження в локальну пам'ять
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomName': roomName,
      'co2': co2,
      'temp': temp,
      'humidity': humidity,
      'iconKey': iconKey,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'status': status,
    };
  }

  // Для читання з локальної пам'яті
  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['id'].toString(),
      roomName: json['roomName'] ?? 'Unknown',
      co2: json['co2'] ?? 0,
      temp: (json['temp'] ?? 0.0).toDouble(),
      humidity: json['humidity'] ?? 0,
      iconKey: json['iconKey'] ?? 'sensors',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      status: json['status'] ?? 'normal',
    );
  }

  // Для читання з API (JSONPlaceholder)
  factory Sensor.fromApi(Map<String, dynamic> json) {
    final int idInt = json['id'] as int;
    final String title = json['title'] as String;

    // Генеруємо реалістичні показники на основі ID та заголовку
    final random = title.hashCode % 100;
    final baseTemp = 18.0 + (random % 12); // 18-30°C
    final humidity = 30 + (random % 40); // 30-70%
    final co2 = 350 + (random % 800); // 350-1150 ppm

    // Визначаємо статус на основі показників
    String sensorStatus = 'normal';
    if (co2 > 1000 || baseTemp > 28 || humidity > 70) {
      sensorStatus = 'warning';
    }
    if (co2 > 1500 || baseTemp > 35 || humidity > 85) {
      sensorStatus = 'critical';
    }

    return Sensor(
      id: idInt.toString(),
      roomName: _generateRoomName(title),
      co2: co2,
      temp: double.parse(baseTemp.toStringAsFixed(1)),
      humidity: humidity,
      iconKey: _getIconForTitle(title),
      lastUpdated: DateTime.now(),
      status: sensorStatus,
    );
  }

  static String _generateRoomName(String title) {
    final words = title.split(' ');
    if (words.isNotEmpty) {
      final firstWord = words.first;
      if (firstWord.length > 3) {
        return '${firstWord[0].toUpperCase()}${firstWord.substring(1)} Room';
      }
    }
    return 'Smart Room';
  }

  static String _getIconForTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('kitchen') || lowerTitle.contains('cook')) {
      return 'kitchen';
    } else if (lowerTitle.contains('bed') || lowerTitle.contains('sleep')) {
      return 'bed';
    } else if (lowerTitle.contains('bath') || lowerTitle.contains('shower')) {
      return 'shower';
    } else if (lowerTitle.contains('office') || lowerTitle.contains('work')) {
      return 'desktop';
    } else if (lowerTitle.contains('garage') || lowerTitle.contains('car')) {
      return 'garage';
    } else {
      return 'home';
    }
  }

  // Методи для перевірки статусу
  bool get isNormal => status == 'normal';
  bool get isWarning => status == 'warning';
  bool get isCritical => status == 'critical';

  // Метод для отримання кольору статусу
  Color get statusColor {
    switch (status) {
      case 'warning':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  // Метод для отримання опису статусу
  String get statusDescription {
    switch (status) {
      case 'warning':
        return 'Потрібно перевірити умови';
      case 'critical':
        return 'Критичні умови! Необхідно втручання';
      default:
        return 'Умови в нормі';
    }
  }
}
