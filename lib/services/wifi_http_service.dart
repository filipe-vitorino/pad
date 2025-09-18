import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../models/sensor_data.dart';
import '../models/device_config.dart';

// --- Constantes de Configuração ---
const String TARGET_WIFI_PREFIX = "ESP32_Sensor_Server";
const String ESP32_DEFAULT_IP = "192.168.4.1";

class WifiHttpService {
  // --- Padrão Singleton ---
  WifiHttpService._privateConstructor();
  static final WifiHttpService _instance =
      WifiHttpService._privateConstructor();
  factory WifiHttpService() => _instance;

  // --- Notifiers de Estado ---
  final ValueNotifier<List<WiFiAccessPoint>> scanResults = ValueNotifier([]);
  final ValueNotifier<bool> isScanning = ValueNotifier(false);
  final ValueNotifier<SensorData?> sensorData = ValueNotifier(null);
  final ValueNotifier<String> connectionStatus = ValueNotifier(
    "Aguardando conexão...",
  );
  Timer? _pollingTimer;

  /// Solicita as permissões necessárias para o scan de Wi-Fi.
  Future<void> requestPermissions() async {
    await Permission.location.request();
  }

  /// Inicia o scan por redes Wi-Fi próximas.
  Future<void> startScan() async {
    if (isScanning.value) return;
    isScanning.value = true;
    scanResults.value = [];
    final can = await WiFiScan.instance.canStartScan();
    if (can == CanStartScan.yes) {
      await WiFiScan.instance.startScan();
      final results = await WiFiScan.instance.getScannedResults();
      scanResults.value =
          results
              .where((ap) => ap.ssid.startsWith(TARGET_WIFI_PREFIX))
              .toList();
    } else {
      connectionStatus.value =
          "Erro: $can. Verifique as permissões e a localização.";
    }
    isScanning.value = false;
  }

  /// Inicia a busca periódica (polling) de dados do sensor em tempo real.
  void startFetchingData({String deviceIp = ESP32_DEFAULT_IP}) {
    stopFetchingData();
    _fetchData(deviceIp);
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 2),
      (timer) => _fetchData(deviceIp),
    );
  }

  /// Para a busca periódica de dados.
  void stopFetchingData() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    sensorData.value = null;
    connectionStatus.value = "Monitoramento parado.";
  }

  /// Método privado que executa a requisição HTTP para os dados em tempo real.
  Future<void> _fetchData(String deviceIp) async {
    try {
      final url = Uri.parse('http://$deviceIp/dados');
      final response = await http.get(url).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        sensorData.value = SensorData.fromJson(jsonDecode(response.body));
        connectionStatus.value = "Conectado e recebendo dados";
      } else {
        connectionStatus.value = "Erro no servidor: ${response.statusCode}";
      }
    } catch (e) {
      connectionStatus.value = "Erro de conexão. Verifique o Wi-Fi.";
    }
  }

  /// Busca o histórico de dados via paginação.
  Future<List<SensorData>> fetchHistoryPage(
    int page,
    int limit, {
    String deviceIp = ESP32_DEFAULT_IP,
  }) async {
    try {
      final url = Uri.parse(
        'http://$deviceIp/historico?page=$page&limit=$limit',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((item) => SensorData.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Falha ao buscar a página de dados: $e');
    }
  }

  /// Envia o comando para o ESP32 apagar os seus logs.
  Future<bool> clearDeviceHistory({String deviceIp = ESP32_DEFAULT_IP}) async {
    try {
      final url = Uri.parse('http://$deviceIp/limpar_historico');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Envia o timestamp atual para o dispositivo.
  Future<bool> sendTimeToDevice({String deviceIp = ESP32_DEFAULT_IP}) async {
    try {
      final url = Uri.parse('http://$deviceIp/set-time');
      final timestamp =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final response = await http
          .post(url, body: timestamp)
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Busca o ficheiro de configuração (config.json) do ESP32 via HTTP.
  Future<DeviceConfig?> fetchConfig({
    String deviceIp = ESP32_DEFAULT_IP,
  }) async {
    try {
      final url = Uri.parse('http://$deviceIp/config');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return DeviceConfig.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
