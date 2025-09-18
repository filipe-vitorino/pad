import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/ble_service.dart';

class DeviceActionsViewModel extends ChangeNotifier {
  final BleService _bleService = BleService();

  ValueNotifier<BluetoothConnectionState> get connectionState =>
      _bleService.connectionState;
  String get deviceName => _bleService.connectedDeviceName;

  DeviceActionsViewModel() {
    _bleService.connectionState.addListener(notifyListeners);
  }
  @override
  void dispose() {
    _bleService.connectionState.removeListener(notifyListeners);
    super.dispose();
  }
}
