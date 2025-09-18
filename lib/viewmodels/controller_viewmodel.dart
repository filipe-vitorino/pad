import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/ble_service.dart';
import '../models/sensor_data.dart';
import '../models/device_config.dart';

class ControllerViewModel extends ChangeNotifier {
  final BleService _bleService = BleService();
  bool _isStreaming = false;
  bool _configFetched = false;

  BluetoothConnectionState get connectionState =>
      _bleService.connectionState.value;
  SensorData? get realTimeData => _bleService.sensorData.value;
  bool get isStreaming => _isStreaming;
  DeviceConfig? get config => _bleService.deviceConfig.value;

  ControllerViewModel() {
    _bleService.sensorData.addListener(notifyListeners);
    _bleService.deviceConfig.addListener(notifyListeners);
    _bleService.connectionState.addListener(_onConnectionStateChanged);
  }

  void _onConnectionStateChanged() {
    notifyListeners();
    if (connectionState == BluetoothConnectionState.connected &&
        !_configFetched) {
      _configFetched = true;
      _bleService.fetchConfig();
    }
  }

  void toggleStreaming(bool enabled) {
    _isStreaming = enabled;
    if (_isStreaming) {
      _bleService.startRealTimeStream();
    } else {
      _bleService.stopRealTimeStream();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    if (_isStreaming) _bleService.stopRealTimeStream();
    _bleService.sensorData.removeListener(notifyListeners);
    _bleService.deviceConfig.removeListener(notifyListeners);
    _bleService.connectionState.removeListener(_onConnectionStateChanged);
    super.dispose();
  }
}
