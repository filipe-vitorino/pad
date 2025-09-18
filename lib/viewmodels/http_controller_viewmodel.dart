import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../models/device_config.dart';
import '../services/wifi_http_service.dart';

class HttpControllerViewModel extends ChangeNotifier {
  final WifiHttpService _wifiService = WifiHttpService();
  final String deviceName;

  DeviceConfig? _deviceConfig;
  DeviceConfig? get config => _deviceConfig;

  bool _isLoadingConfig = true;
  bool get isLoadingConfig => _isLoadingConfig;

  SensorData? get sensorData => _wifiService.sensorData.value;
  String get connectionStatus => _wifiService.connectionStatus.value;
  bool get hasError => connectionStatus.toLowerCase().contains('erro');

  HttpControllerViewModel({required this.deviceName}) {
    _wifiService.sensorData.addListener(notifyListeners);
    _wifiService.connectionStatus.addListener(notifyListeners);
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoadingConfig = true;
    notifyListeners();

    await _wifiService.sendTimeToDevice();
    _deviceConfig = await _wifiService.fetchConfig();

    _isLoadingConfig = false;
    notifyListeners();

    _wifiService.startFetchingData();
  }

  @override
  void dispose() {
    _wifiService.stopFetchingData();
    _wifiService.sensorData.removeListener(notifyListeners);
    _wifiService.connectionStatus.removeListener(notifyListeners);
    super.dispose();
  }
}
