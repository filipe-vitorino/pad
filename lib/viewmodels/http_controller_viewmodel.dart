/*
 * Título: ViewModel do Controlador HTTP
 * Descrição: Gerencia o estado e os dados recebidos via HTTP do ESP32.
 * Autor: Gemini
 * Data: 01 de Agosto de 2025
*/

import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/wifi_http_service.dart';

class HttpControllerViewModel extends ChangeNotifier {
  final WifiHttpService _wifiService = WifiHttpService();
  final String deviceName;

  SensorData? get sensorData => _wifiService.sensorData.value;
  String get connectionStatus => _wifiService.connectionStatus.value;
  bool get hasError => connectionStatus.toLowerCase().contains('erro');

  HttpControllerViewModel({required this.deviceName}) {
    _wifiService.sensorData.addListener(notifyListeners);
    _wifiService.connectionStatus.addListener(notifyListeners);
    // O serviço começa a buscar os dados. O IP pode ser passado como parâmetro se não for o padrão.
    _wifiService.startFetchingData();
  }

  @override
  void dispose() {
    // ESSENCIAL: Para o polling de dados quando a tela é fechada
    _wifiService.stopFetchingData();
    _wifiService.sensorData.removeListener(notifyListeners);
    _wifiService.connectionStatus.removeListener(notifyListeners);
    super.dispose();
  }
}
