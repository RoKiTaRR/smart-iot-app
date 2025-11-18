import 'dart:convert';

class Sensor {
  Sensor({
    required this.id,
    required this.roomName,
    required this.co2,
    required this.temp,
    required this.humidity,
    required this.iconKey,
  });

  final String id;
  String roomName;
  int co2;
  double temp;
  int humidity;
  String iconKey;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomName': roomName,
      'co2': co2,
      'temp': temp,
      'humidity': humidity,
      'iconKey': iconKey,
    };
  }

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['id'] as String,
      roomName: json['roomName'] as String,
      co2: json['co2'] as int,
      temp: json['temp'] as double,
      humidity: json['humidity'] as int,
      iconKey: json['iconKey'] as String,
    );
  }

  Sensor copyWith({
    String? roomName,
    int? co2,
    double? temp,
    int? humidity,
    String? iconKey,
  }) {
    return Sensor(
      id: id,
      roomName: roomName ?? this.roomName,
      co2: co2 ?? this.co2,
      temp: temp ?? this.temp,
      humidity: humidity ?? this.humidity,
      iconKey: iconKey ?? this.iconKey,
    );
  }
}