import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/ble_service.dart';

class ScannerViewModel extends ChangeNotifier {
  final BleService _bleService = BleService();

  List<ScanResult> get scanResults => _bleService.scanResults.value;
  bool get isScanning => _bleService.isScanning.value;

  ScannerViewModel() {
    // Adiciona listeners aos ValueNotifiers do serviço
    _bleService.scanResults.addListener(_onStateChanged);
    _bleService.isScanning.addListener(_onStateChanged);

    // Inicia o scan automaticamente se o bluetooth estiver ligado
    _checkAdapterAndScan();
  }

  void _checkAdapterAndScan() {
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {
        startScan();
      }
    });
  }

  void startScan() {
    _bleService.startScan();
  }

  void stopScan() {
    _bleService.stopScan();
  }

  void _onStateChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    // Remove os listeners para evitar memory leaks
    _bleService.scanResults.removeListener(_onStateChanged);
    _bleService.isScanning.removeListener(_onStateChanged);
    super.dispose();
  }
}
