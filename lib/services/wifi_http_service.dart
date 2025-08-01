/*
 * Título: Serviço de Wi-Fi e HTTP
 * Descrição: Gerencia o escaneamento e conexão a redes Wi-Fi,
 * e a busca de dados via HTTP de um servidor (ESP32).
 * Autor: Gemini
 * Data: 01 de Agosto de 2025
*/

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../models/sensor_data.dart';

const String TARGET_WIFI_PREFIX = "ESP32_Sensor_Server";
const String ESP32_DEFAULT_IP = "192.168.4.1";

class WifiHttpService {
  // Padrão Singleton
  WifiHttpService._privateConstructor();
  static final WifiHttpService _instance =
      WifiHttpService._privateConstructor();
  factory WifiHttpService() => _instance;

  // Notifiers para o estado que a UI vai observar
  final ValueNotifier<List<WiFiAccessPoint>> scanResults = ValueNotifier([]);
  final ValueNotifier<bool> isScanning = ValueNotifier(false);
  final ValueNotifier<SensorData?> sensorData = ValueNotifier(null);
  final ValueNotifier<String> connectionStatus = ValueNotifier(
    "Aguardando conexão...",
  );

  Timer? _pollingTimer;

  Future<void> requestPermissions() async {
    await Permission.location.request();
  }

  Future<void> startScan() async {
    if (isScanning.value) return;

    isScanning.value = true;
    final canScan = await WiFiScan.instance.canStartScan();
    if (canScan == CanStartScan.yes) {
      await WiFiScan.instance.startScan();
      final results = await WiFiScan.instance.getScannedResults();
      scanResults.value =
          results
              .where((ap) => ap.ssid.startsWith(TARGET_WIFI_PREFIX))
              .toList();
    }
    isScanning.value = false;
  }

  Future<bool> connectToWifi(String ssid, String password) async {
    print("⚙️  DEBUG [SERVICE]: Método 'connectToWifi' chamado.");
    print("⚙️  DEBUG [SERVICE]: Tentando conectar ao SSID: '$ssid'");
    // Por segurança, não vamos logar a senha aqui, mas confirmamos que ela não está vazia.
    print(
      "⚙️  DEBUG [SERVICE]: Senha recebida? ${password.isNotEmpty ? 'Sim' : 'Não (Vazia)'}",
    );

    try {
      // Desconecta de qualquer rede anterior para garantir uma conexão limpa
      await WiFiForIoTPlugin.disconnect();
      final success = await WiFiForIoTPlugin.connect(
        ssid,
        password: password,
        security: NetworkSecurity.WPA,
        joinOnce: true,
      );
      print("➡️  DEBUG [SERVICE]: Plugin retornou o resultado: $success");
      return success;
    } catch (e) {
      print("Erro ao conectar ao Wi-Fi: $e");
      return false;
    }
  }

  void startFetchingData({String deviceIp = ESP32_DEFAULT_IP}) {
    // Para o timer antigo, se houver, antes de iniciar um novo.
    stopFetchingData();

    // Busca os dados imediatamente na primeira vez
    _fetchData(deviceIp);

    // Inicia o polling
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchData(deviceIp);
    });
  }

  void stopFetchingData() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    sensorData.value = null; // Limpa os dados antigos
    connectionStatus.value = "Monitoramento parado.";
  }

  Future<void> _fetchData(String deviceIp) async {
    try {
      final url = Uri.parse('http://$deviceIp/dados');
      final response = await http.get(url).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        sensorData.value = SensorData.fromJson(jsonData);
        connectionStatus.value = "Conectado e recebendo dados";
      } else {
        connectionStatus.value = "Erro no servidor: ${response.statusCode}";
      }
    } catch (e) {
      connectionStatus.value = "Erro de conexão. Verifique o Wi-Fi.";
      print("Erro ao buscar dados HTTP: $e");
    }
  }
}
