import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

enum MqttStatus { connected, connecting, disconnected }

// Сервіс для роботи з MQTT
class MqttService extends ChangeNotifier {
  final MqttServerClient _client =
      MqttServerClient('broker.hivemq.com', 'flutter_client_id_${DateTime.now().millisecondsSinceEpoch}');

  MqttStatus _status = MqttStatus.disconnected;
  MqttStatus get status => _status;

  String _currentTemperature = "---";
  String get currentTemperature => _currentTemperature;

  Future<void> connect() async {
    _status = MqttStatus.connecting;
    notifyListeners(); 

    _client.port = 1883;
    _client.logging(on: false);
    _client.keepAlivePeriod = 20;
    _client.onDisconnected = _onDisconnected;
    _client.onConnected = _onConnected;
    _client.onSubscribed = (topic) => print('Subscribed to $topic');

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(_client.clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client.connectionMessage = connMessage;

    try {
      await _client.connect();
    } catch (e) {
      print('Connection failed: $e');
      _client.disconnect();
    }
  }

  void _onConnected() {
    _status = MqttStatus.connected;
    notifyListeners();
    
    _client.subscribe('sensor/temperature', MqttQos.atMostOnce);

    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final recMess = messages[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      _currentTemperature = payload;
      notifyListeners(); 
    });
  }

  void _onDisconnected() {
    _status = MqttStatus.disconnected;
    notifyListeners();
  }

  void disconnect() {
    _client.disconnect();
  }
}
