import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/ble_service.dart';

class ScannerViewModel extends ChangeNotifier {
  final BleService _bleService = BleService();

  List<ScanResult> get scanResults => _bleService.scanResults.value;
  bool get isScanning => _bleService.isScanning.value;

  ScannerViewModel() {
    _bleService.scanResults.addListener(_onStateChanged);
    _bleService.isScanning.addListener(_onStateChanged);
  }

  void init() {
    _checkAdapterAndScan();
  }

  void _checkAdapterAndScan() {
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {
        startScan();
      }
    });
  }

  void startScan() => _bleService.startScan();
  void stopScan() => _bleService.stopScan();

  /// Notifica os "ouvintes" (a View) de que o estado mudou.
  void _onStateChanged() {
    // CORREÇÃO: Adia a notificação para o próximo ciclo de eventos da UI.
    // Isto quebra a cadeia síncrona de eventos (mudança no serviço -> notificação no viewmodel)
    // e garante que o notifyListeners() nunca seja chamado durante um 'build'.
    Future.delayed(Duration.zero, () {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _bleService.scanResults.removeListener(_onStateChanged);
    _bleService.isScanning.removeListener(_onStateChanged);
    super.dispose();
  }
}
