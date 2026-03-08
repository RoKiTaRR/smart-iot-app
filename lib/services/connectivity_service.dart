import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityService {
  final StreamController<ConnectivityStatus> _controller = StreamController();
  Stream<ConnectivityStatus> get connectionStream => _controller.stream;

  ConnectivityService() {
    // ТУТ БУЛА ПОМИЛКА: (ConnectivityResult result) -> (List<ConnectivityResult> results)
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Для простоти беремо перший результат зі списку
      final status = _getStatusFromResult(results.first);
      _controller.add(status);
    });
  }

  ConnectivityStatus _getStatusFromResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
        return ConnectivityStatus.online;
      case ConnectivityResult.none:
      default:
        return ConnectivityStatus.offline;
    }
  }

  static Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    // Тут теж порівнюємо зі списком
    return !result.contains(ConnectivityResult.none);
  }
}
