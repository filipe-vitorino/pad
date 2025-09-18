import 'package:flutter/material.dart';
import '../services/wifi_http_service.dart';
import '../services/database_service.dart';
import '../models/sensor_data.dart';
import '../models/device_config.dart';

class WifiSyncViewModel extends ChangeNotifier {
  final WifiHttpService _wifiService = WifiHttpService();
  final DatabaseService _dbService = DatabaseService.instance;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  int _recordsDownloaded = 0;
  int get recordsDownloaded => _recordsDownloaded;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<SensorData> _syncedLogs = [];
  List<SensorData> get syncedLogs => _syncedLogs;

  Future<void> syncAllData() async {
    _isSyncing = true;
    _recordsDownloaded = 0;
    _errorMessage = '';
    _syncedLogs = [];
    notifyListeners();

    List<SensorData> allLogs = [];
    DeviceConfig? config;

    final stopwatch = Stopwatch()..start();

    try {
      config = await _wifiService.fetchConfig();
      if (config == null)
        throw Exception("Não foi possível obter a configuração.");

      int currentPage = 1;
      const int limitPerPage = 50;

      while (true) {
        final List<SensorData> pageData = await _wifiService.fetchHistoryPage(
          currentPage,
          limitPerPage,
        );
        if (pageData.isNotEmpty) {
          allLogs.addAll(pageData);
          _recordsDownloaded = allLogs.length;
          notifyListeners();
          currentPage++;
        } else {
          break;
        }
      }

      if (allLogs.isNotEmpty) {
        _syncedLogs = allLogs;
        await _dbService.saveReading(allLogs, config);
        await _wifiService.clearDeviceHistory();
      }
    } catch (e) {
      _errorMessage = "Falha na sincronização: $e";
    } finally {
      _isSyncing = false;
      stopwatch.stop();
      final formattedDuration = (stopwatch.elapsed.inMilliseconds / 1000)
          .toStringAsFixed(2);
      print("⏱️ Sincronização Wi-Fi concluída em $formattedDuration segundos.");
      notifyListeners();
    }
  }
}
