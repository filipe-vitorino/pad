import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/ble_service.dart';
import '../models/sensor_data.dart';
import '../models/device_config.dart';

class ControllerViewModel extends ChangeNotifier {
  final BleService _bleService = BleService();
  bool _isStreaming = false;
  bool _configFetched = false;

  // --- Getters para a View ---
  BluetoothConnectionState get connectionState =>
      _bleService.connectionState.value;
  SensorData? get realTimeData => _bleService.sensorData.value;
  bool get isStreaming => _isStreaming;
  DeviceConfig? get config => _bleService.deviceConfig.value;

  // Construtor SEM o parâmetro 'device'
  ControllerViewModel() {
    _bleService.sensorData.addListener(notifyListeners);
    _bleService.deviceConfig.addListener(notifyListeners);
    _bleService.connectionState.addListener(_onConnectionStateChanged);

    // Se a conexão já estiver ativa, busca a config imediatamente
    if (_bleService.connectionState.value ==
        BluetoothConnectionState.connected) {
      _fetchConfigOnce();
    }
  }

  void _onConnectionStateChanged() {
    notifyListeners();
    // Busca a configuração assim que a conexão for estabelecida
    if (connectionState == BluetoothConnectionState.connected) {
      _fetchConfigOnce();
    }
  }

  void _fetchConfigOnce() {
    if (!_configFetched) {
      _configFetched = true;
      _bleService.fetchConfig();
    }
  }

  /// Verifica se o valor de um sensor específico está dentro dos limites.
  bool isSensorOk(String sensorKey) {
    if (realTimeData == null || config == null) return true;
    double? currentValue;
    final threshold = config!.thresholds[sensorKey];
    switch (sensorKey) {
      case 'temperatura':
        currentValue = realTimeData!.temperatura;
        break;
      case 'vazao':
        currentValue = realTimeData!.vazao;
        break;
      case 'pressao':
        currentValue = realTimeData!.pressao;
        break;
      case 'volume':
        currentValue = realTimeData!.volume;
        break;
      case 'tds':
        currentValue = realTimeData!.tds;
        break;
    }
    if (currentValue == null || threshold == null) return true;
    bool isAboveMax = (threshold.max != null && currentValue > threshold.max!);
    bool isBelowMin = (threshold.min != null && currentValue < threshold.min!);
    return !isAboveMax && !isBelowMin;
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
