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

  // Для збереження в локальну пам'ять
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

  // Для читання з локальної пам'яті
  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['id'].toString(),
      roomName: json['roomName'] ?? 'Unknown',
      co2: json['co2'] ?? 0,
      temp: (json['temp'] ?? 0.0).toDouble(),
      humidity: json['humidity'] ?? 0,
      iconKey: json['iconKey'] ?? 'sensors',
    );
  }

  // НОВЕ: Для читання з Інтернету (фейковий API)
  factory Sensor.fromApi(Map<String, dynamic> json) {
    final int idInt = json['id'] as int;
    return Sensor(
      id: idInt.toString(),
      // Беремо заголовок посту як назву кімнати
      roomName: (json['title'] as String).split(' ').first.toUpperCase() + ' Room',
      // Генеруємо фейкові показники на основі ID
      co2: 400 + (idInt * 20),
      temp: 18.0 + (idInt % 10),
      humidity: 30 + (idInt % 40),
      iconKey: idInt % 2 == 0 ? 'kitchen' : 'desktop',
    );
  }
}
