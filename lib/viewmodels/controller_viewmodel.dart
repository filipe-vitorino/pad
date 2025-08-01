import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/ble_service.dart';
import '../models/sensor_data.dart';

class ControllerViewModel extends ChangeNotifier {
  final BleService _bleService = BleService();
  final BluetoothDevice device;

  ControllerViewModel({required this.device}) {
    _bleService.connectionState.addListener(_onStateChanged);
    _bleService.sensorData.addListener(_onStateChanged);
    _connect();
  }

  // Getters para expor os dados para a View
  BluetoothConnectionState get connectionState =>
      _bleService.connectionState.value;
  SensorData? get sensorData => _bleService.sensorData.value;
  String get connectionStatusText {
    switch (connectionState) {
      case BluetoothConnectionState.connected:
        return 'Conectado';
      case BluetoothConnectionState.connecting:
        return 'Conectando...';
      case BluetoothConnectionState.disconnected:
        return 'Desconectado';
      case BluetoothConnectionState.disconnecting:
        return 'Desconectando...';
    }
  }

  void _connect() {
    _bleService.connectToDevice(device);
  }

  void _onStateChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _bleService.disconnect();
    _bleService.connectionState.removeListener(_onStateChanged);
    _bleService.sensorData.removeListener(_onStateChanged);
    super.dispose();
  }
}
