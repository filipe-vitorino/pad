import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/sensor_data.dart';

const String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
const String CHARACTERISTIC_UUID_TX =
    "beb5483e-36e1-4688-b7f5-ea07361b26a8"; // ESP32 envia, App recebe
const String CHARACTERISTIC_UUID_RX =
    "f48ebb2c-442a-4732-b0b3-009758a2f9b1"; // App envia, ESP32 recebe
const String TARGET_DEVICE_PREFIX = "ESP32_BLE_";

class BleService {
  // Padrão Singleton para garantir uma única instância do serviço
  BleService._privateConstructor();
  static final BleService _instance = BleService._privateConstructor();
  factory BleService() => _instance;

  // Notifiers para o estado que a UI vai observar
  final ValueNotifier<List<ScanResult>> scanResults = ValueNotifier([]);
  final ValueNotifier<bool> isScanning = ValueNotifier(false);
  final ValueNotifier<BluetoothConnectionState> connectionState = ValueNotifier(
    BluetoothConnectionState.disconnected,
  );
  final ValueNotifier<SensorData?> sensorData = ValueNotifier(null);

  // Características e assinaturas (subscriptions)
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _rxCharacteristic;
  BluetoothCharacteristic? _txCharacteristic;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _valueSubscription;

  void startScan() {
    if (isScanning.value) return;

    scanResults.value = [];
    isScanning.value = true;

    // Inicia o scan
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

    // Escuta os resultados
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      final filteredResults =
          results
              .where(
                (r) => r.device.platformName.startsWith(TARGET_DEVICE_PREFIX),
              )
              .toList();
      filteredResults.sort((a, b) => b.rssi.compareTo(a.rssi));
      scanResults.value = filteredResults;
    });

    // Para o indicador de "escaneando" após o timeout
    Future.delayed(const Duration(seconds: 15), stopScan);
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
    isScanning.value = false;
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    stopScan();
    _connectedDevice = device;
    connectionState.value = BluetoothConnectionState.connecting;

    _connectionSubscription = device.connectionState.listen((state) async {
      connectionState.value = state;
      if (state == BluetoothConnectionState.connected) {
        await _discoverServices();
      } else {
        // Limpa os dados se desconectar
        sensorData.value = null;
      }
    });

    try {
      await device.connect(timeout: const Duration(seconds: 15));
    } catch (e) {
      print("Erro ao conectar: $e");
      disconnect();
    }
  }

  Future<void> _discoverServices() async {
    if (_connectedDevice == null) return;
    try {
      List<BluetoothService> services =
          await _connectedDevice!.discoverServices();
      for (var s in services) {
        if (s.uuid.toString() == SERVICE_UUID) {
          for (var c in s.characteristics) {
            if (c.uuid.toString() == CHARACTERISTIC_UUID_TX)
              _txCharacteristic = c;
            if (c.uuid.toString() == CHARACTERISTIC_UUID_RX)
              _rxCharacteristic = c;
          }
        }
      }
      _setupNotifications();
    } catch (e) {
      print("Erro ao descobrir serviços: $e");
    }
  }

  void _setupNotifications() async {
    if (_txCharacteristic == null || !_txCharacteristic!.properties.notify) {
      print(
        "Característica de notificação (TX) não encontrada ou não suportada.",
      );
      return;
    }

    await _txCharacteristic!.setNotifyValue(true);
    _valueSubscription = _txCharacteristic!.onValueReceived.listen((value) {
      String jsonDataString = utf8.decode(value, allowMalformed: true);
      print("JSON String Recebido: $jsonDataString");

      try {
        Map<String, dynamic> jsonData = jsonDecode(jsonDataString);
        sensorData.value = SensorData.fromJson(jsonData);
        _sendAck(); // Envia confirmação após receber e processar os dados
      } catch (e) {
        print(
          "Erro ao decodificar JSON: $e. String recebida: '$jsonDataString'",
        );
      }
    });
  }

  Future<void> _sendAck() async {
    if (_rxCharacteristic == null) {
      print(
        "Característica RX (ACK) não encontrada. Não é possível enviar ACK.",
      );
      return;
    }
    try {
      // Escreve com resposta para garantir que o ESP32 recebeu
      await _rxCharacteristic!.write([0x01], withoutResponse: false);
      print("ACK Enviado para o ESP32.");
    } catch (e) {
      print("Erro ao enviar ACK: $e");
    }
  }

  void disconnect() {
    _connectionSubscription?.cancel();
    _valueSubscription?.cancel();
    _connectedDevice?.disconnect();
    _connectedDevice = null;
    connectionState.value = BluetoothConnectionState.disconnected;
    sensorData.value = null;
  }
}
