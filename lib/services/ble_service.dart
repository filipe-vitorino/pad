import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/sensor_data.dart';
import '../models/device_config.dart';

const String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
const String CHARACTERISTIC_UUID_TX = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
const String CHARACTERISTIC_UUID_RX = "f48ebb2c-442a-4732-b0b3-009758a2f9b1";
const String TARGET_DEVICE_PREFIX_BLE = "ESP32_BLE_";

class BleService {
  BleService._privateConstructor();
  static final BleService _instance = BleService._privateConstructor();
  factory BleService() => _instance;

  BluetoothDevice? _connectedDevice;
  String connectedDeviceName = "Dispositivo";

  final ValueNotifier<List<ScanResult>> scanResults = ValueNotifier([]);
  final ValueNotifier<bool> isScanning = ValueNotifier(false);
  final ValueNotifier<BluetoothConnectionState> connectionState = ValueNotifier(
    BluetoothConnectionState.disconnected,
  );
  final ValueNotifier<SensorData?> sensorData = ValueNotifier(null);
  final ValueNotifier<DeviceConfig?> deviceConfig = ValueNotifier(null);
  final ValueNotifier<bool> isSyncing = ValueNotifier(false);
  final ValueNotifier<int> totalRecordsToReceive = ValueNotifier(0);
  final ValueNotifier<int> recordsReceived = ValueNotifier(0);
  final List<SensorData> syncedData = [];

  BluetoothCharacteristic? _rxCharacteristic;
  BluetoothCharacteristic? _txCharacteristic;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _valueSubscription;
  Completer<DeviceConfig?>? _configCompleter;

  void startScan() {
    if (isScanning.value) return;
    scanResults.value = [];
    isScanning.value = true;
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      final filteredResults =
          results
              .where(
                (r) =>
                    r.device.platformName.startsWith(TARGET_DEVICE_PREFIX_BLE),
              )
              .toList();
      filteredResults.sort((a, b) => b.rssi.compareTo(a.rssi));
      scanResults.value = filteredResults;
    });
    Future.delayed(const Duration(seconds: 15), stopScan);
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
    isScanning.value = false;
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    if (connectionState.value == BluetoothConnectionState.connected &&
        _connectedDevice?.remoteId == device.remoteId) {
      return true;
    }
    disconnect();
    await Future.delayed(const Duration(milliseconds: 100));

    _connectedDevice = device;
    connectionState.value = BluetoothConnectionState.connecting;

    _connectionSubscription = device.connectionState.listen((state) async {
      connectionState.value = state;
      if (state == BluetoothConnectionState.connected) {
        await _discoverServices();
      }
    });

    try {
      await device.connect(timeout: const Duration(seconds: 15));
      await Future.delayed(const Duration(milliseconds: 500));
      if (connectionState.value == BluetoothConnectionState.connected) {
        connectedDeviceName =
            device.platformName.isNotEmpty
                ? device.platformName
                : "Dispositivo Desconhecido";
        return true;
      }
      return false;
    } catch (e) {
      print("Erro de conexão: $e");
      disconnect();
      return false;
    }
  }

  void disconnect() {
    print("🧹 BLE Service: Limpeza completa da conexão e estado.");
    _connectionSubscription?.cancel();
    _valueSubscription?.cancel();
    _scanSubscription?.cancel();
    _connectedDevice?.disconnect();
    _connectedDevice = null;
    _rxCharacteristic = null;
    _txCharacteristic = null;

    connectionState.value = BluetoothConnectionState.disconnected;
    sensorData.value = null;
    deviceConfig.value = null;
    isSyncing.value = false;
    totalRecordsToReceive.value = 0;
    recordsReceived.value = 0;
    scanResults.value = [];
    isScanning.value = false;
    syncedData.clear();
  }

  Future<void> _discoverServices() async {
    if (_connectedDevice == null) return;
    print("ℹ️ DESCOBERTA: A procurar por serviços e características...");
    try {
      List<BluetoothService> services =
          await _connectedDevice!.discoverServices();
      for (var service in services) {
        if (service.uuid.toString().toLowerCase() ==
            SERVICE_UUID.toLowerCase()) {
          _txCharacteristic = service.characteristics.firstWhere(
            (c) =>
                c.uuid.toString().toLowerCase() ==
                CHARACTERISTIC_UUID_TX.toLowerCase(),
          );
          _rxCharacteristic = service.characteristics.firstWhere(
            (c) =>
                c.uuid.toString().toLowerCase() ==
                CHARACTERISTIC_UUID_RX.toLowerCase(),
          );
        }
      }
      if (_txCharacteristic != null && _rxCharacteristic != null) {
        print(
          "🏁 DESCOBERTA: Sucesso! Todas as características foram encontradas.",
        );
        await _setupNotifications();
      } else {
        print(
          "🏁 DESCOBERTA: FALHA! Uma ou mais características não foram encontradas.",
        );
      }
    } catch (e) {
      print("❌ ERRO FATAL durante a descoberta de serviços: $e");
    }
  }

  Future<void> _setupNotifications() async {
    if (_txCharacteristic == null || !_txCharacteristic!.properties.notify)
      return;
    await _txCharacteristic!.setNotifyValue(true);
    _valueSubscription = _txCharacteristic!.onValueReceived.listen((value) {
      String jsonDataString = utf8.decode(value, allowMalformed: true);
      print("📥 FLUTTER: Dados brutos recebidos: $jsonDataString");
      try {
        Map<String, dynamic> jsonData = jsonDecode(jsonDataString);
        String? type = jsonData['type'];
        if (type == null) {
          sensorData.value = SensorData.fromJson(jsonData);
        } else if (type == 'SOT') {
          totalRecordsToReceive.value = jsonData['records'];
          _sendAck();
        } else if (type == 'data') {
          syncedData.add(SensorData.fromJson(jsonData));
          recordsReceived.value++;
          _sendAck();
        } else if (type == 'EOT') {
          isSyncing.value = false;
        } else if (type == 'config') {
          final config = DeviceConfig.fromJson(jsonData['data']);
          deviceConfig.value = config;
          print(
            "✅ Configuração recebida e processada pelo listener principal.",
          );

          // Se houver uma "promessa" pendente do fetchConfig, cumpra-a.
          if (_configCompleter != null && !_configCompleter!.isCompleted) {
            _configCompleter!.complete(config);
          }
        }
      } catch (e) {
        print("❌ ERRO FLUTTER: Falha ao decodificar JSON: $e");
        isSyncing.value = false;
      }
    });
  }

  Future<void> _sendAck() async {
    if (_rxCharacteristic == null) return;
    try {
      await _rxCharacteristic!.write([0x01], withoutResponse: false);
    } catch (e) {
      print("Erro ao enviar ACK: $e");
    }
  }

  Future<void> requestHistoricalData() async {
    if (_rxCharacteristic == null) return;
    isSyncing.value = true;
    recordsReceived.value = 0;
    totalRecordsToReceive.value = 0;
    syncedData.clear();
    await _rxCharacteristic!.write([0x02], withoutResponse: false);
  }

  Future<void> confirmSaveAndRequestDelete() async {
    if (_rxCharacteristic == null) return;
    await _rxCharacteristic!.write([0x06], withoutResponse: false);
  }

  Future<void> startRealTimeStream() async {
    if (_rxCharacteristic == null) return;
    await _rxCharacteristic!.write([0x03], withoutResponse: false);
  }

  Future<void> stopRealTimeStream() async {
    if (_rxCharacteristic == null) return;
    await _rxCharacteristic!.write([0x05], withoutResponse: false);
  }

  Future<DeviceConfig?> fetchConfig() async {
    if (_rxCharacteristic == null) return null;

    // 1. Cria uma nova "promessa" de que receberemos uma configuração
    _configCompleter = Completer<DeviceConfig?>();

    try {
      // 2. Envia o comando para pedir a configuração
      print("📲 FLUTTER: A enviar comando para pedir config (0x20)...");
      await _rxCharacteristic!.write([0x20], withoutResponse: false);

      // 3. Aguarda que a "promessa" seja cumprida pelo listener principal (com timeout)
      print("⏳ FLUTTER: A aguardar resposta da configuração...");
      return await _configCompleter!.future.timeout(
        const Duration(seconds: 15),
      );
    } catch (e) {
      print("❌ Timeout ou erro ao esperar pela configuração: $e");
      // Garante que o completer seja finalizado em caso de erro
      if (!_configCompleter!.isCompleted) {
        _configCompleter!.complete(null);
      }
      return null;
    }
  }

  void cancelSync() {
    isSyncing.value = false; // Força a paragem do estado de sync na UI
    // A desconexão será tratada pela View que detém a sessão
    print("🛑 FLUTTER: Pedido para cancelar a sincronização.");
  }
}
