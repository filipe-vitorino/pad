import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/ble_service.dart';
import '../models/sensor_data.dart';
import '../services/database_service.dart';
import '../models/device_config.dart';

class SyncViewModel extends ChangeNotifier {
  final BleService _bleService = BleService();
  final DatabaseService _dbService = DatabaseService.instance;

  bool _wasCancelled = false;
  DeviceConfig? _fetchedConfig;

  bool get wasCancelled => _wasCancelled;
  BluetoothConnectionState get connectionState =>
      _bleService.connectionState.value;
  bool get isSyncing => _bleService.isSyncing.value;
  int get recordsReceived => _bleService.recordsReceived.value;
  int get totalRecordsToReceive => _bleService.totalRecordsToReceive.value;
  List<SensorData> get syncedData => _bleService.syncedData;
  double get syncProgress {
    if (totalRecordsToReceive == 0) return 0.0;
    return recordsReceived / totalRecordsToReceive;
  }

  SyncViewModel() {
    _bleService.connectionState.addListener(notifyListeners);
    _bleService.recordsReceived.addListener(notifyListeners);
    _bleService.totalRecordsToReceive.addListener(notifyListeners);
    _bleService.isSyncing.addListener(_onSyncStateChanged);
  }

  Future<bool> initializeSync() async {
    _wasCancelled = false;
    print("Iniciando negociação: buscando configuração...");
    _fetchedConfig = await _bleService.fetchConfig();

    if (_fetchedConfig == null) {
      print("Falha ao buscar configuração. Abortando sync.");
      return false;
    }

    print("Configuração recebida. Iniciando transferência de logs...");
    await _bleService.requestHistoricalData();
    return true;
  }

  void cancelSync() {
    _wasCancelled = true;
    _bleService
        .cancelSync(); // Apenas avisa o serviço para parar, não desconecta
    notifyListeners();
  }

  void _onSyncStateChanged() async {
    if (!_bleService.isSyncing.value &&
        _bleService.recordsReceived.value > 0 &&
        !_wasCancelled) {
      if (_fetchedConfig != null) {
        try {
          await _dbService.saveReading(syncedData, _fetchedConfig!);
          await Future.delayed(const Duration(milliseconds: 500));
          await _bleService.confirmSaveAndRequestDelete();
        } catch (e) {
          print("❌ ERRO ao salvar ou apagar: $e");
        }
      } else {
        print(
          "❌ ERRO CRÍTICO: Sincronização terminou, mas a configuração era nula.",
        );
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    // Apenas remove os listeners. Não desconecta.
    _bleService.connectionState.removeListener(notifyListeners);
    _bleService.recordsReceived.removeListener(notifyListeners);
    _bleService.totalRecordsToReceive.removeListener(notifyListeners);
    _bleService.isSyncing.removeListener(_onSyncStateChanged);
    super.dispose();
  }
}
